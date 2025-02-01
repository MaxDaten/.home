{ pkgs, ... }: {
  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    # https://starship.rs/config/
    settings = {
      # Inserts a blank line between shell prompts
      add_newline = true;

      line_break = { disabled = false; };

      format = pkgs.lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_status"
        "$package"
        "$all"
        "$kubernetes"
        "$line_break"
        "$nix_shell$shell$character"
      ];

      right_format =
        pkgs.lib.concatStrings [ "$direnv" "$time" "$cmd_duration" ];

      kubernetes = {
        disabled = false;
        format = "[\\[$symbol$context( \\($namespace\\))\\]]($style) ";
        context_aliases = { };
      };

      direnv = { disabled = false; };

      shell = {
        fish_indicator = "🐡";
        bash_indicator = ">_";
        disabled = false;
      };

      time = {
        format = "[$time]($style) ";
        disabled = false;
      };

      cmd_duration = {
        format = "[~$duration]($style) ";
        disabled = false;
        style = "bold #505050";
      };

      docker_context.disabled = true;

      nix_shell = {
        format = "$symbol$state";
        impure_msg = "";
        pure_msg = "+";
      };
      gcloud.disabled = true;

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };
}
