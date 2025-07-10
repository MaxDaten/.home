{ config, pkgs, ... }: {

  home.packages = with pkgs; [ zed-editor ];

  xdg.configFile."zed/settings.json".text = builtins.toJSON {
    features = { edit_prediction_provider = "zed"; };
    assistant = {
      default_model = {
        provider = "anthropic";
        model = "claude-opus-4-latest";
      };
      version = "2";
    };
    buffer_font_fallbacks = ["JetBrainsMono Nerd Font"];
    ui_font_size = 16;
    buffer_font_size = 12;
    ui_font_features = { calt = true; };
    base_keymap = "JetBrains";
    theme = {
      mode = "system";
      light = "One Light";
      dark = "One Dark";
    };
    terminal = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = 14;
    };
    languages = {
      Nix = { language_servers = [ pkgs.nixd "!nil" ]; };
      JavaScript = { format_on_save = "off"; };
    };
    lsp = {
      nixd = {
        binary = { path_lookup = true; };
        settings = { formatting = { command = [ pkgs.nixfmt ]; }; };
      };
      terraform = { binary = { path_lookup = true; }; };
      tinymist = {
        initialization_options = {
          exportPdf = "onSave";
          outputPath = "$root/$name";
        };
      };
    };
  };
}
