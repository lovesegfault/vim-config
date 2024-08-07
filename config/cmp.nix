{ config, lib, ... }: {
  # upstream module does not provide nvim-cmp integration yet
  extraConfigLua = lib.mkIf config.plugins.nvim-autopairs.enable (lib.mkAfter /* lua */ ''
    -- HACK: nvim-autopairs integration with cmp, relies on mkAfter
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  '');

  plugins = {
    cmp = {
      enable = true;
      autoEnableSources = false;
      settings = {
        experimental.ghost_text = true;
        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-e>" = "cmp.mapping.close()";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
        };
        snippet.expand = ''
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
              option = {
                ignore_cmds = [
                  "Man"
                  "!"
                ];
              };
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
    luasnip = {
      enable = true;
      fromVscode = [{ }];
    };
  };
}
