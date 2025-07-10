{ lib, ... }: {
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
      line_break.disabled = false;

      palette = "gruvbox_dark";

      # Custom palette colors
      palettes.spaceship = {
        bright-purple = "#b16cfe";
        bright-cyan = "#00ffff";
        bright-blue = "#00aaff";
      };

      palettes.gruvbox_dark = {
        color_fg0 = "#fbf1c7";
        color_bg1 = "#3c3836";
        color_bg3 = "#665c54";
        color_blue = "#458588";
        color_aqua = "#689d6a";
        color_green = "#98971a";
        color_orange = "#d65d0e";
        color_purple = "#b16286";
        color_red = "#cc241d";
        color_yellow = "#d79921";
      };


      format = lib.replaceStrings ["\n"] [""] ''
        [](color_orange)
        $os
        $username
        [](bg:color_yellow fg:color_orange)
        $directory
        $nix_shell
        [](fg:color_yellow bg:color_aqua)
        $git_branch
        $git_status
        [](fg:color_aqua bg:color_blue)
        [$all](fg:color_aqua bg:color_blue)
        [](fg:color_blue bg:color_bg3)
        $docker_context
        $kubernetes
        $aws
        $gcloud
        $azure
        [](fg:color_bg3 bg:color_bg1)
        $time
        $cmd_duration
        $memory_usage
        [ ](fg:color_bg1)
        $line_break$jobs$shell$status$character '';

      os = {
        disabled = false;
        style = "bg:color_orange fg:color_fg0";
        symbols = {
          Windows = "󰍲";
          Ubuntu = "󰕈";
          SUSE = "";
          Raspbian = "󰐿";
          Mint = "󰣭";
          Macos = "󰀵";
          Manjaro = "";
          Linux = "󰌽";
          Gentoo = "󰣨";
          Fedora = "󰣛";
          Alpine = "";
          Amazon = "";
          Android = "";
          Arch = "󰣇";
          Artix = "󰣇";
          EndeavourOS = "";
          CentOS = "";
          Debian = "󰣚";
          Redhat = "󱄛";
          RedHatEnterprise = "󱄛";
          Pop = "";
        };
      };

      # Project View
      directory = {
        style = "fg:color_fg0 bg:color_yellow";
        format = "[ $path ]($style)[$read_only]($read_only_style)";
        truncation_length = 3;
        truncate_to_repo = true;
        truncation_symbol = "…/";
      };

      username = {
        disabled = false;
        style_user = "bg:color_orange fg:color_fg0";
        style_root = "bg:color_orange fg:color_fg0";
        format = "[ $user ]($style)";
        show_always = true;
      };

      nix_shell = {
        format = "[ $symbol$state ]($style)";
        impure_msg = "";
        pure_msg = "λ";
        symbol = "";
        style = "fg:color_fg0 bg:color_yellow";
      };

      git_branch = {
        style = "bg:color_aqua";
        format = "[[ $symbol$branch ](fg:color_fg0 bg:color_aqua)]($style)";
      };

      git_status = {
        style = "bg:color_aqua";
        format = "[[($all_status$ahead_behind )](fg:color_fg0 bg:color_aqua)]($style)";
      };

      # Cloud View

      kubernetes = {
        disabled = false;
        format = "[[ $symbol( $context(:$namespace)) ](fg:#83a598 bg:color_bg3)]($style)";
        symbol = "";
        style = "bg:color_bg3";
        contexts = [{
          context_pattern = "gke_.*_(?P<cluster>[\\w-]+)";
          context_alias = "gke-$cluster";
        }];
      };

      docker_context = {
        disabled = false;
        format = "[[ $symbol( $context) ](fg:#83a598 bg:color_bg3)]($style)";
        symbol = "";
        style = "bg:color_bg3";
      };

      gcloud = {
        disabled = false;
        format = "[[ $symbol( $account(@$domain)(($region)) )](fg:#83a598 bg:color_bg3)]($style)";
        symbol = "";
        style = "bg:color_bg3";
      };

      # Languages

      terraform.disabled = false;
      package = {
        disabled = false;
        format = "[[ $symbol( $version) ](fg:#83a598 bg:color_bg3)]($style)";
        symbol = "📦";
        style = "bg:color_bg3";
      };

      nodejs = {
        disabled = false;
        format = "[[ $symbol($version) ](fg:color_fg0 bg:color_blue)]($style)";
        style = "bg:color_blue";
      };


      # System View

      time = {
        disabled = false;
        format = "[[  $time ](fg:color_fg0 bg:color_bg1)]($style)";
        style = "bg:color_bg1";
        time_format = "%R";
      };

      memory_usage = {
        disabled = false;
        threshold = -1;
        format = "[[ $symbol$ram ](fg:#716965 bg:color_bg1)]($style)";
        symbol = "";
        style = "bg:color_bg1";
      };

      cmd_duration = {
        format = "[[  $duration ](fg:#716965 bg:color_bg1)]($style)";
        style = "bg:color_bg1";
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
    };
  };
}
