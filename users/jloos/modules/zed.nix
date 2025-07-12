{ pkgs, ... }:
{

  home.packages = with pkgs; [ zed-editor ];

  xdg.configFile."zed/settings.json".text = builtins.toJSON {
    # UI and theme settings
    theme = {
      mode = "system";
      light = "One Light";
      dark = "One Dark";
    };
    base_keymap = "JetBrains";

    # Font settings
    ui_font_size = 16;
    ui_font_features = {
      calt = true;
    };
    buffer_font_size = 12;
    buffer_font_fallbacks = [ "JetBrainsMono Nerd Font" ];
    terminal = {
      font_family = "JetBrainsMono Nerd Font";
      line_height = "standard";
      font_size = 14;
    };

    # Features
    features = {
      edit_prediction_provider = "zed";
    };

    # Assistant
    assistant = {
      default_model = {
        provider = "anthropic";
        model = "claude-opus-4-latest";
      };
      version = "2";
    };

    # Language-specific settings
    languages = {
      Nix = {
        language_servers = [
          pkgs.nixd
          "!nil"
        ];
      };
      JavaScript = {
        format_on_save = "off";
      };
    };

    # LSP configurations
    lsp = {
      nixd = {
        binary = {
          path_lookup = true;
        };
        settings = {
          formatting = {
            command = [ pkgs.nixfmt-rfc-style ];
          };
        };
      };
      terraform = {
        binary = {
          path_lookup = true;
        };
      };
      tinymist = {
        initialization_options = {
          exportPdf = "onSave";
          outputPath = "$root/$name";
        };
      };
    };
  };
}
