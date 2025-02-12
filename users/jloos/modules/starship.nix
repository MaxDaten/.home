{ ... }: {
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    # https://starship.rs/config/
    settings = {
      # Inserts a blank line between shell prompts
      add_newline = false;

      line_break = { disabled = true; };

      format = ''
        [┌─❮](dimmed green)$time$kubernetes$packages$all[❯](dimmed green)
        [│](dimmed green)$directory$git_branch$git_status
        [└─❮](dimmed green)$nix_shell$shell$status$character'';

      right_format = "$direnv$cmd_duration";

      kubernetes = {
        disabled = false;
        format = "[\\[$symbol$context:$namespace\\]]($style) ";
        symbol = "🧊 ";
        context_aliases = { };
      };

      direnv = { disabled = false; };

      shell = {
        fish_indicator = "";
        disabled = false;
      };

      time = {
        format = "[$time]($style)";
        style = "dimmed yellow";
        disabled = false;
      };

      cmd_duration = {
        format = "[~$duration]($style) ";
        disabled = false;
        style = "bold #505050";
      };

      nix_shell = {
        format = "$symbol$state";
        impure_msg = "[λ](bold red)";
        pure_msg = "[λ](bold green)";
        symbol = "❄️";
      };

      docker_context.disabled = true;
      gcloud.disabled = true;

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        format = "$symbol";
      };

      status = {
        style = "bold red";
        symbol = "✗";
        disabled = false;
      };
    };
  };
}
