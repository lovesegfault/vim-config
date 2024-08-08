{ config, lib, pkgs, ... }: {
  plugins = {
    lsp = {
      enable = true;
      inlayHints = true;
      keymaps = {
        diagnostic = {
          "[d" = "goto_prev";
          "]d" = "goto_next";
          "<space>e" = "open_float";
        };
        lspBuf = {
          "ca" = "code_action";
          "gD" = "declaration";
          "gd" = "definition";
          "K" = "hover";
          "gi" = "implementation";
          "gr" = "references";
          "<space>D" = "type_definition";
          "<space>rn" = "rename";
        };
        extra = lib.mkMerge [
          [{
            key = "<space>f";
            mode = [ "n" "v" ];
            action = lib.nixvim.mkRaw /* lua */ ''
              function()
                vim.lsp.buf.format({ async = true })
              end
            '';
            options.desc = "Format the current buffer";
          }]
          (lib.mkIf config.plugins.telescope.enable [
            {
              key = "gd";
              mode = [ "n" "v" ];
              action = lib.nixvim.mkRaw "require('telescope.builtin').lsp_definitions";
              options.desc = "View LSP definitions in telescope";
            }
            {
              key = "gi";
              mode = [ "n" "v" ];
              action = lib.nixvim.mkRaw "require('telescope.builtin').lsp_implementations";
              options.desc = "View LSP implementations in telescope";
            }
            {
              key = "gr";
              mode = [ "n" "v" ];
              action = lib.nixvim.mkRaw "require('telescope.builtin').lsp_references";
              options.desc = "View LSP references in telescope";
            }
            {
              key = "<space>D";
              mode = [ "n" "v" ];
              action = lib.nixvim.mkRaw "require('telescope.builtin').lsp_type_definitions";
              options.desc = "View LSP type definitions in telescope";
            }
          ])
        ];
      };
      servers = {
        bashls.enable = true;
        clangd.enable = true;
        ltex.enable = true;
        lua-ls = {
          enable = true;
          settings = {
            runtime.version = "LuaJIT";
            workspace.library = [ (lib.nixvim.mkRaw "vim.api.nvim_get_runtime_file('', true)") ];
          };
        };
        marksman.enable = true;
        nil-ls = {
          enable = true;
          settings.formatting.command = [ (lib.getExe pkgs.nixpkgs-fmt) ];
        };
        ruff.enable = true;
        pyright.enable = true;
        texlab.enable = true;
      };
    };
    clangd-extensions.enable = true;
    ltex-extra.enable = true;
    rustaceanvim.enable = true;
    fidget.enable = true;
  };
}
