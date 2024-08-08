{ config, lib, ... }: {
  # upstream module does not provide nvim-cmp integration yet
  extraConfigLua = lib.mkIf config.plugins.nvim-autopairs.enable (lib.mkAfter /* lua */ ''
    -- HACK: nvim-autopairs integration with cmp, relies on mkAfter
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  '');

  # Automatic session cancellation for luasnip
  # c.f. https://github.com/L3MON4D3/LuaSnip/issues/258
  autoCmd = [{
    desc = "automatically cancel luasnip session when changing mode";
    event = [ "ModeChanged" ];
    pattern = "*";
    callback = lib.nixvim.mkRaw ''
      function()
        local luasnip = require("luasnip")
        if
          ((vim.v.event.old_mode == "s" and vim.v.event.new_mode == "n") or vim.v.event.old_mode == "i")
          and luasnip.session.current_nodes[vim.api.nvim_get_current_buf()]
          and not luasnip.session.jump_active
        then
          luasnip.unlink_current()
        end
      end
    '';

  }];

  plugins = {
    cmp = {
      enable = true;
      autoEnableSources = false;
      settings = {
        view.entries = {
          name = "custom";
          selection_order = "near_cursor";
        };
        experimental.ghost_text = true;
        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-e>" = "cmp.mapping.close()";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";

          "<CR>" = /* lua */ ''
            cmp.mapping({
              i = function(fallback)
                if cmp.visible() and cmp.get_active_entry() then
                  local luasnip = require("luasnip")
                  if luasnip.expandable() then
                    luasnip.expand()
                  else
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                  end
                else
                  fallback()
                end
              end,
              s = function(fallback)
                if cmp.visible() then
                  local luasnip = require("luasnip")
                  if luasnip.expandable() then
                    luasnip.expand()
                  else
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
                  end
                else
                  fallback()
                end
              end,
              c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
            })
          '';
          "<Tab>" = /* lua */ ''
            cmp.mapping(function(fallback)
              local luasnip = require("luasnip")
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.locally_jumpable(1) then
                luasnip.jump(1)
              else
                fallback()
              end
            end, { "i", "s" })
          '';
          "<S-Tab>" = /* lua */ ''
            cmp.mapping(function(fallback)
              local luasnip = require("luasnip")
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" })
          '';
        };
        snippet.expand = /* lua */ ''
          function(args)
            require('luasnip').lsp_expand(args.body)
          end
        '';
        sources = [
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          { name = "treesitter"; }
          { name = "buffer"; }
          { name = "tmux"; }
          { name = "async_path"; }
        ];
      };
      cmdline = {
        "/" = {
          mapping = lib.nixvim.mkRaw "cmp.mapping.preset.cmdline()";
          sources = [
            { name = "buffer"; }
            { name = "treesitter"; }
            { name = "tmux"; }
          ];
        };
        ":" = {
          mapping = lib.nixvim.mkRaw "cmp.mapping.preset.cmdline()";
          sources = [
            { name = "path"; }
            {
              name = "cmdline";
              option.ignore_cmds = [ "Man" "!" ];
            }
          ];
        };
      };
    };
    cmp-async-path.enable = true;
    cmp-buffer.enable = true;
    cmp-cmdline.enable = true;
    cmp-nvim-lsp.enable = true;
    cmp-tmux.enable = true;
    cmp-treesitter.enable = true;
    cmp_luasnip.enable = true;
    lspkind = {
      enable = true;
      mode = "symbol_text";
      cmp = {
        enable = true;
        maxWidth = 50;
        ellipsisChar = "…";
      };
    };
    luasnip.enable = true;
    friendly-snippets.enable = true;
  };
}
