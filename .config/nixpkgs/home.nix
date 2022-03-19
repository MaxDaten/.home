{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jloos";
  home.homeDirectory = "/Users/jloos";

  home.packages = with pkgs; [
    htop
    ripgrep
    watch
    tree
    wget
    pwgen
    dive
    gnupg
    direnv

    terminal-notifier
    peco
    broot
    jq
    jless

    # fonts
    jetbrains-mono

    # linting
    shellcheck
    
    # Nix tools
    comma
    nixfmt

    # Infrastructure
    awscli2
    google-cloud-sdk
    kubectl
    kustomize
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Configurations

  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "peco";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-peco";
          rev = "0a3282c9522c4e0102aaaa36f89645d17db78657";
          sha256 = "005r6yar254hkx6cpd2g590na812mq9z9a17ghjl6sbyyxq24jhi";
        };
      }

      {
        name = "foreign-env";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-foreign-env";
          rev = "dddd9213272a0ab848d474d0cbde12ad034e65bc";
          # SRI hash
          hash = "sha256-er1KI2xSUtTlQd9jZl1AjqeArrfBxrgBLcw5OqinuAM=";
        };
      }

      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "45a9ff6d0932b0e9835cbeb60b9794ba706eef10";
          hash = "sha256-pWkEhjbcxXduyKz1mAFo90IuQdX7R8bLCQgb0R+hXs4=";
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

      {
        # https://github.com/franciscolourenco/done
        name = "done";
        src = pkgs.fetchFromGitHub {
          owner = "franciscolourenco";
          repo = "done";
          rev = "d6abb267bb3fb7e987a9352bc43dcdb67bac9f06";
          hash = "sha256-6oeyN9ngXWvps1c5QAUjlyPDQwRWAoxBiVTNmZ4sG8E=";
        };
      }

      {
        # https://github.com/lilyball/nix-env.fish
        name = "nix-env";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          hash = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }

      {
        # https://github.com/laughedelic/pisces
        name = "pisces";
        src = pkgs.fetchFromGitHub {
          owner = "laughedelic";
          repo = "pisces";
          rev = "e45e0869855d089ba1e628b6248434b2dfa709c4";
          hash = "sha256-Oou2IeNNAqR00ZT3bss/DbhrJjGeMsn9dBBYhgdafBw=";
        };
      }
    ];

    shellAbbrs = {
      hm = "home-manager";
      hms = "home-manager switch";
      gitco = "git checkout";
      gitrb = "git rebase --autostash";
      gitcm = "git commit -m";
      pjo = "pj open";
    };

    shellAliases = {
      k = "kubectl";
      br = "broot";
    };

    shellInit = ''
      # nix
      if test -e /Users/jloos/.nix-profile/etc/profile.d/nix.sh
          fenv source /Users/jloos/.nix-profile/etc/profile.d/nix.sh
      end

      # home-manager
      set -gpx NIX_PATH "$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels"
    '';

    interactiveShellInit = ''
      set fish_greeting "🐡"

      # peco
      function fish_user_key_bindings
        bind \cr 'peco_select_history (commandline -b)'
      end

      set -gx PROJECT_PATHS ~/Workspace/buzzar ~/Workspace/kmo ~/Workspace/gitops
      set -gx EDITOR code

      # done
      set __done_enabled
    '';

    functions = {
      gitignore = "curl -sL https://www.gitignore.io/api/$argv";
      fish_reload = "source ~/.config/fish/config.fish";
    };
  };

  programs.bat.enable = true;

  # Git
  programs.git = {
    enable = true;
    userName = "Jan-Philip Loos";
    userEmail = "maxdaten@gmail.com";

    aliases = { r = "rebase --autostash"; };

    extraConfig = {
      core = {
        autocrlf = "input";
        excludesfile = "/Users/jloos/.config/git/global.gitignore";
      };

      pull = { rebase = false; };

      init = { defaultBranch = "main"; };
    };
  };

  # Vim
  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = ''
      colorscheme gruvbox
    '';

    plugins = with pkgs.vimPlugins; [
      gruvbox

      # Languages
      vim-nix

      vim-fish

      vim-go

      vim-pandoc
      vim-pandoc-syntax
    ];

  };
}
