{
  imports = [
    ./core.nix

    ./bufferline.nix
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
    which-key.enable = true;
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
  };
}
