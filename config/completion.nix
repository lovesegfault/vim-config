{
  plugins = {
    blink-cmp = {
      enable = true;
      settings = {
        appearance.use_nvim_cmp_as_default = true;
        completion = {
          list.selection.preselect = false;
          documentation = {
            auto_show = true;
            window.border = "rounded";
          };
          ghost_text.enabled = true;
        };
        signature = {
          enabled = true;
          window.border = "rounded";
        };
        keymap = {
          preset = "enter";
          "<Tab>" = [
            "select_next"
            "fallback"
          ];
          "<S-Tab>" = [
            "select_prev"
            "fallback"
          ];
          "<C-n>" = [
            "snippet_forward"
            "fallback"
          ];
          "<C-p>" = [
            "snippet_backward"
            "fallback"
          ];
        };
      };
    };
    friendly-snippets.enable = true;
  };
}
