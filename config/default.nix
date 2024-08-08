{ config, lib, pkgs, ... }: {
  imports = [
    ./cmp.nix
    ./core.nix
    ./lsp.nix
    ./lualine.nix
    ./telescope.nix
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
    dap.enable = true;
    dressing.enable = true;
    gitsigns.enable = true;
    guess-indent.enable = true;
    indent-blankline = {
      enable = true;
      settings.indent.char = "▏";
    };
    multicursors.enable = true;
    nix-develop.enable = true;
    notify.enable = true;
    nvim-autopairs.enable = true;
    sleuth.enable = true;
    tmux-navigator.enable = true;
    todo-comments = {
      enable = true;
      keymaps.todoTelescope.key = "<leader>tc";
    };
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

  extraPlugins = with pkgs.vimPlugins; [
    vim-suda
    whitespace-nvim
  ];

  extraConfigLua = ''
    require("whitespace-nvim").setup({
      ignored_filetypes = { "TelescopePrompt", "dashboard", "help" },
    })
  '';

  keymaps = lib.mkMerge [
    [
      {
        key = "<space>w";
        action = lib.nixvim.mkRaw "require('whitespace-nvim').trim";
        mode = [ "n" ];
        options.desc = "Trim leading/trailing whitespace";
      }
    ]
    (lib.mkIf config.plugins.notify.enable [{
      key = "<C-d>";
      action = lib.nixvim.mkRaw "require('notify').dismiss";
      mode = [ "n" "v" "i" ];
      options.desc = "Dismiss nvim-notify notifications";
    }])
    (lib.mkIf config.plugins.multicursors.enable [
      {
        key = "ms";
        action = ":MCstart<cr>";
        mode = [ "n" "v" ];
        options.desc = "Select the word under the cursor and start listening for the actions";
      }
      {
        key = "mp";
        action = ":MCvisualPattern<cr>";
        mode = [ "v" ];
        options.desc = "Prompts for a pattern and selects every match in the visual selection";
      }
      {
        key = "mp";
        action = ":MCpattern<cr>";
        mode = [ "n" ];
        options.desc = "Prompts for a pattern and selects every match in the buffer";
      }
      {
        key = "mc";
        action = ":MCclear<cr>";
        mode = [ "n" "v" ];
        options.desc = "Clears all multicursor selections";
      }
    ])
  ];
}
