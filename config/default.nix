{ config, lib, ... }: {
  imports = [
    ./core.nix
    ./lsp.nix
  ];

  viAlias = true;
  vimAlias = true;
  withRuby = false;

  luaLoader.enable = true;

  clipboard = {
    register = "unnamedplus";
    providers = {
      wl-copy.enable = true;
      xclip.enable = true;
    };
  };

  colorschemes.ayu.enable = true;

  plugins = {
    bufferline = {
      enable = true;
      diagnostics = lib.mkIf config.plugins.lsp.enable "nvim_lsp";
    };
    dressing.enable = true;
    sleuth.enable = true;
    tmux-navigator.enable = true;
    notify.enable = true;
    treesitter = {
      enable = true;
      nixGrammars = true;
      gccPackage = null;
      nodejsPackage = null;
      treesitterPackage = null;
      settings = {
        auto_install = false;
        highlight.enable = true;
        indent.enable = true;
        incremental_selection.enable = true;
      };
    };
    which-key.enable = true;
  };

  keymaps = lib.mkMerge [
    (lib.mkIf config.plugins.notify.enable [{
      key = "<C-d>";
      action = lib.nixvim.mkRaw "require('notify').dismiss";
      mode = ["n" "v" "i"];
      options.desc = "Dismiss nvim-notify notifications";
    }])
  ];
}
