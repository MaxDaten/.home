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
        "$custom"
        "$directory"
        "$git_branch"
        "$git_status"
        "$package"
        "$all"
        "$kubernetes"
        "$cmd_duration"
        "$line_break"
        "$nix_shell$shell$character"
      ];

      kubernetes = {
        disabled = false;
        format = "[\\[$symbol$context( \\($namespace\\))\\]]($style) ";
        context_aliases = { };
      };

      custom = {
        direnv_basename = {
          command = ''basename "''${DIRENV_DIR/#-/~}"'';
          when = ''
            [[ -n "$DIRENV_DIR" ]]''; # Only show when in a direnv directory & loaded env
          format = "[$output;]($style) ";
          shell = [ "bash" ];
          style = "red bold";
        };
      };

      shell = {
        fish_indicator = "🐡";
        bash_indicator = ">_";
        disabled = false;
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
