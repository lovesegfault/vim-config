{ config, lib, ... }: {
  plugins = {
    navic = {
      enable = true;
      lsp.autoAttach = true;
    };
    lualine =
      let
        filetype = {
          name = "filetype";
          extraConfig.icon_only = true;
        };
        filename = {
          name = "filename";
          extraConfig.symbols = {
            modified = "●";
            readonly = "🔒";
            unnamed = "[No Name]";
            newfile = "[New]";
          };
        };
        diff = {
          name = "diff";
          extraConfig.symbols = {
            added = " ";
            modified = " ";
            removed = " ";
          };
        };
        diagnostics = {
          name = "diagnostics";
          extraConfig.sources = [ "nvim_lsp" ];
          extraConfig.symbols = {
            error = " ";
            warn = " ";
            info = " ";
            hint = " ";
          };
        };
      in
      {
        enable = true;
        theme = lib.mkIf config.colorschemes.ayu.enable "ayu_dark";
        sectionSeparators = {
          left = "";
          right = "";
        };
        componentSeparators = {
          left = "";
          right = "";
        };
        sections = {
          lualine_a = [ "mode" ];
          lualine_b = [ filetype filename "navic" ];
          lualine_c = [
            diagnostics
          ];
          lualine_x = [ "searchcount" diff "branch" ];
          lualine_y = [ "encoding" "fileformat" ];
          lualine_z = [ "location" "progress" ];
        };
        inactiveSections = {
          lualine_a = [ ];
          lualine_b = [ ];
          lualine_c = [ filetype filename ];
          lualine_x = [ "location" ];
          lualine_y = [ ];
          lualine_z = [ ];
        };
      };
  };
}
