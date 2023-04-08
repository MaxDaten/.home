{
  pkgs,
  isDarwin,
  config,
  lib,
  ...
}: {
  programs.fish.enable = true;
  programs.fish = {
    plugins = [
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "foreign-env";
        src = pkgs.fishPlugins.foreign-env.src;
      }
      {
        name = "colored-man-pages";
        src = pkgs.fishPlugins.colored-man-pages.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        # https://github.com/lilyball/nix-env.fish
        # Setup nix environment in fish shell + completions of packages
        name = "nix-env";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          hash = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }
      {
        name = "pj";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-pj";
          rev = "43c94f24fd53a55cb6b01400b9b39eb3b6ed7e4e";
          hash = "sha256-/4c/52HLvycTPjuiMKC949XYLPNJUhedd3xEV/ioxfw=";
        };
      }
    ];

    shellAbbrs = lib.mkMerge [
      {
        gitco = "git checkout";
        gitrb = "git rebase --autostash";
        gitcm = "git commit -m";
        gitca = "git commit --amend --no-edit";
        pjo = "pj open";
        awse = "code --new-window ~/.aws/credentials ~/.aws/config";
        tp = "terraform plan";
        ta = "terraform apply";
        tay = "terraform apply --yes";
        # Handy for nix shells with deep folder structures
        cdr = "cd $PRJ_ROOT";
      }
      (lib.mkIf isDarwin {
        hme = "home-manager edit --flake ${config.home.homeDirectory}/Workspace/.home/#jloos-macos";
        hms = "home-manager switch --flake ${config.home.homeDirectory}/Workspace/.home/#jloos-macos";
      })
    ];

    shellAliases = {
      k = "kubectl";
      br = "broot";
      ls = "${pkgs.lsd}/bin/lsd -l";
      h = "hey_gpt";
    };

    shellInit = ''
      set -U fish_greeting
      set -U PROJECT_PATHS ~/Workspace/buzzar ~/Developer/kmo ~/Workspace/gitops ~/Workspace/.home
      set -U FZF_COMPLETION_TRIGGER '~~'
      set __done_enabled
    '';

    functions = let
      gpt_functions = import ../fish-functions/gpt.nix;
    in {
      inherit (gpt_functions) hey_gpt data_gpt;
      gitignore = "curl -sL https://www.gitignore.io/api/$argv";
      fish_reload = "source ~/.config/fish/config.fish";
    };
  };
}
