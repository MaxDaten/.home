{ ... }: {
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    # https://starship.rs/config/
    settings = {
      # Inserts a blank line between shell prompts
      add_newline = true;

      line_break = { disabled = false; };

      format = ''
        [┌─❮](dimmed green)$time$kubernetes$package[❯](dimmed green)
        [│](dimmed green)$directory$git_branch$git_status
        [└─❮](dimmed green)$nix_shell$shell$character'';

      right_format = "$direnv$cmd_duration";

      kubernetes = {
        disabled = false;
        format = "[\\[$symbol$context( \\($namespace\\))\\]]($style) ";
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
        impure_msg = "[-](bold red)";
        pure_msg = "[+](bold green)";
        symbol = "❄️";
      };

      docker_context.disabled = true;
      gcloud.disabled = true;

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[✗](bold red)";
        format = "$symbol";
      };
    };
  };
}
