{ lib, ... }: {
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
        extra = [
          {
            key = "<space>f";
            action = lib.nixvim.mkRaw /* lua */ ''
              function()
                vim.lsp.buf.format({ async = true })
              end
            '';
            options.desc = "Format the current buffer";
          }
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
        nil-ls.enable = true;
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
