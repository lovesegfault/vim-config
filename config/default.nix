{
  config,
  lib,
  pkgs,
  ...
}:
{
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
      settings.options.diagnostics = lib.mkIf config.plugins.lsp.enable "nvim_lsp";
    };
    dap = {
      enable = true;
      extensions.dap-ui.enable = true;
    };
    dressing.enable = true;
    gitsigns.enable = true;
    guess-indent.enable = true;
    indent-blankline = {
      enable = true;
      settings.indent.char = "▏";
    };
    multicursors.enable = true;
    nix-develop.enable = true;
    noice = {
      enable = true;
      settings = {
        lsp.override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
          "cmp.entry.get_documentation" = true;
        };
        presets = {
          bottom_search = true; # use a classic bottom cmdline for search
          command_palette = true; # position the cmdline and popupmenu together
          long_message_to_split = true; # long messages will be sent to a split
          inc_rename = false; # enables an input dialog for inc-rename.nvim
          lsp_doc_border = true; # add a border to hover docs and signature help
        };
      };
    };
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
    trim = {
      enable = true;
      settings = rec {
        ft_blocklist = [
          "TelescopePrompt"
          "dashboard"
          "help"
        ];
        highlight = true;
        # highlight_ctermbg = "DiffDelete";
        highlight_bg = lib.nixvim.mkRaw "vim.api.nvim_get_hl(0, {name= 'DiffDelete'}).bg";
        highlight_ctermbg = highlight_bg;
        trim_first_line = false;
        trim_last_line = false;
        trim_on_write = false;
      };
    };
    vim-matchup = {
      enable = true;
      enableSurround = true;
    };
    vim-suda.enable = true;
    web-devicons.enable = true;
    which-key.enable = true;
  };

  keymaps = lib.mkMerge [
    [
      {
        key = "<space>w";
        action = ":Trim";
        mode = [ "n" ];
        options.desc = "Trim leading/trailing whitespace";
      }
    ]
    (lib.mkIf config.plugins.notify.enable [
      {
        key = "<C-d>";
        action = lib.nixvim.mkRaw "require('notify').dismiss";
        mode = [
          "n"
          "v"
          "i"
        ];
        options.desc = "Dismiss nvim-notify notifications";
      }
    ])
    (lib.mkIf config.plugins.multicursors.enable [
      {
        key = "ms";
        action = ":MCstart<cr>";
        mode = [
          "n"
          "v"
        ];
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
        mode = [
          "n"
          "v"
        ];
        options.desc = "Clears all multicursor selections";
      }
    ])
  ];
}
