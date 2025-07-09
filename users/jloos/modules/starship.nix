{ ... }: {
  programs.starship = let I = "[|](bold bright-black)";
  in {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    # https://starship.rs/config/
    settings = {
      # Inserts a blank line between shell prompts
      add_newline = false;
      line_break.disabled = true;

      format = ''
        [╭─](bold bright-purple)[](dimmed white) $directory\[$nix_shell\] $git_branch$git_status
        [│ ](bold bright-purple)[⚡](bright-yellow)${I}$shell$all
        [│ ](bold bright-purple)[🌐](bright-blue)${I}$docker_context$kubernetes$aws$gcloud$azure
        [╰─](bold bright-purple)[$time](dimmed yellow) $character '';

      right_format = "$cmd_duration$memory_usage$jobs$battery";

      # Custom palette colors
      palette = "spaceship";
      palettes.spaceship = {
        bright-purple = "#b16cfe";
        bright-cyan = "#00ffff";
        bright-blue = "#00aaff";
      };

      # Module configurations
      time = {
        format = "[⏱️  $time]($style)";
        style = "dimmed yellow";
        disabled = false;
        time_format = "%H:%M:%S";
      };

      battery = {
        format = "[$symbol$percentage]($style) ";
        charging_symbol = "⚡️ ";
        discharging_symbol = "🔋 ";
        display = [
          {
            threshold = 10;
            style = "bold red";
          }
          {
            threshold = 30;
            style = "bold yellow";
          }
          {
            threshold = 100;
            style = "bold green";
          }
        ];
      };

      memory_usage = {
        disabled = false;
        threshold = -1;
        format = "[$symbol $ram]($style) ";
        symbol = "";
        style = "bold dimmed white";
      };

      directory = {
        style = "bold bright-cyan";
        format = "[$path]($style)[$read_only]($read_only_style) ";
        truncation_length = 3;
        truncate_to_repo = true;
        substitutions = {
          "Documents" = "📄";
          "Downloads" = "📥";
          "Developer" = "💻";
          "~" = "🏠";
        };
      };

      kubernetes = {
        disabled = false;
        format = "[\\[$symbol$context:$namespace\\]]($style) ";
        symbol = "";
        style = "bright-blue";
        contexts = [{
          context_pattern = "gke_.*_(?P<cluster>[\\w-]+)";
          context_alias = "gke-$cluster";
        }];
      };

      docker_context = {
        disabled = false;
        format = "[$symbol$context]($style) ";
        symbol = "";
        style = "blue";
      };

      terraform.disabled = false;

      gcloud = {
        disabled = false;
        format = "[$symbol $account(@$domain)(($region))]($style)";
        symbol = "";
        style = "bold blue";
      };

      nix_shell = {
        format = "$symbol$state";
        impure_msg = "[λ](bold red)";
        pure_msg = "[λ](bold green)";
        symbol = "";
      };

      cmd_duration = {
        format = "[⏱️  $duration]($style) ";
        style = "bold bright-black";
        min_time = 2000;
        show_milliseconds = false;
        show_notifications = true;
        min_time_to_notify = 45000;
      };

      jobs = {
        disabled = false;
        format = "[$symbol$number]($style) ";
        symbol = "✦ ";
        style = "bold blue";
        number_threshold = 1;
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        format = "$symbol";
      };

      status = {
        style = "bold red";
        symbol = "✗ ";
        format = "[$symbol$common_meaning$signal_name$maybe_int]($style) ";
        map_symbol = true;
        disabled = false;
      };

      shell = {
        disabled = false;
        format = "[$indicator]($style) ";
        fish_indicator = "🐟";
        bash_indicator = "🐚";
        style = "cyan bold";
      };

      username = {
        disabled = false;
        style_user = "bold yellow";
        style_root = "bold red";
        format = "[$user]($style) ";
        show_always = false;
      };

    };
  };
}
