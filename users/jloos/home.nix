{
  config,
  lib,
  pkgs,
  headless ? true,
  ...
}: let
  nixos-vscode-server = fetchTarball {
    url = "https://github.com/msteen/nixos-vscode-server/tarball/master";
    sha256 = "sha256:00ki5z2svrih9j9ipl8dm3dl6hi9wgibydsfa7rz2mdw9p0370yl";
  };

  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  darwinPackages = with pkgs; [
    terminal-notifier
  ];

  guiPackages = with pkgs; [
    # fonts
    jetbrains-mono
    nerdfonts
  ];
in {
  imports = [
    "${nixos-vscode-server}/modules/vscode-server/home.nix"
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

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jloos";
  home.homeDirectory =
    if isDarwin
    then "/Users/jloos"
    else "/home/jloos";

  home.packages = with pkgs;
    [
      gnupg
      direnv
      htop

      peco

      # shell tools
      spaceship-prompt
      htop
      ripgrep
      watch
      tree
      wget
      pwgen
      neofetch

      broot

      # Data Structures
      jq
      yq
      jless
      dasel # Query data structures
      gron # transforms to grepable jsons

      # linting
      shellcheck

      # Nix tools
      comma
      nixfmt
      alejandra

      # Infrastructure
      awscli2
      google-cloud-sdk
      kubectl
      kustomize
      dive # Analyze docker layer
    ]
    ++ lib.optional isDarwin darwinPackages
    ++ lib.optional (!headless) guiPackages;

  services.vscode-server.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Configurations
  programs.man.generateCaches = true; # Allow man completions

  home.sessionVariables = {
    EDITOR =
      if isDarwin
      then "code --wait"
      else "vim";
  };

  programs.tmux = {
    enable = true;
    tmuxinator.enable = true;
    clock24 = true;
    plugins = with pkgs; [
      tmuxPlugins.cpu
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60' # minutes
        '';
      }
    ];
  };

  programs.fish = {
    enable = true;

    plugins = [
      {
        # https://github.com/oh-my-fish/plugin-peco
        name = "peco";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-peco";
          rev = "0a3282c9522c4e0102aaaa36f89645d17db78657";
          sha256 = "005r6yar254hkx6cpd2g590na812mq9z9a17ghjl6sbyyxq24jhi";
        };
      }

      {
        # https://github.com/oh-my-fish/plugin-foreign-env
        name = "foreign-env";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-foreign-env";
          rev = "b3dd471bcc885b597c3922e4de836e06415e52dd";
          # SRI hash
          hash = "sha256-er1KI2xSUtTlQd9jZl1AjqeArrfBxrgBLcw5OqinuAM=";
        };
      }

      {
        # https://github.com/jethrokuan/z
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "85f863f20f24faf675827fb00f3a4e15c7838d76";
          hash = "sha256-+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
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
      hme = "home-manager edit";
      hms = "NIXPKGS_ALLOW_BROKEN=1 home-manager switch";
      gitco = "git checkout";
      gitrb = "git rebase --autostash";
      gitcm = "git commit -m";
      gitca = "git commit --amend --no-edit";
      pjo = "pj open";
      awse = "code --new-window ~/.aws/credentials ~/.aws/config";
      tp = "terraform plan";
      ta = "terraform apply";
      tay = "terraform apply --yes";
    };

    shellAliases = {
      k = "kubectl";
      br = "broot";
    };

    shellInit = ''
      # nix
      if test -e $HOME/.nix-profile/etc/profile.d/nix.sh
        fenv source $HOME/.nix-profile/etc/profile.d/nix.sh
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
      # set -gx EDITOR code

      # done
      set __done_enabled
    '';

    functions = {
      gitignore = "curl -sL https://www.gitignore.io/api/$argv";
      fish_reload = "source ~/.config/fish/config.fish";
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      # Inserts a blank line between shell prompts
      add_newline = true;

      line_break = {disabled = false;};

      format = pkgs.lib.concatStrings [
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
        context_aliases = {
          "k8s-cluster01.prelive.kmo.zone" = "kmo-prelive";
          "k8s-cluster01.live.kmo.zone" = "kmo-live";
        };
      };

      shell = {
        fish_indicator = "🐡";
        bash_indicator = ">_";
        disabled = false;
      };

      docker_context = {disabled = true;};

      nix_shell = {
        format = "$symbol$state";
        impure_msg = "";
        pure_msg = "+";
      };

      nodejs = {
        # Fix missing space after symbol
        symbol = " ";
      };

      java = {disabled = false;};

      gcloud = {disabled = true;};

      aws = {disabled = false;};

      scala = {format = "[$symbol($version )]($style) ";};

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  programs.bat.enable = true;
  programs.bash.enable = true;
  programs.zsh.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Git
  programs.git = {
    enable = true;
    userName = "Jan-Philip Loos";
    userEmail = "maxdaten@gmail.com";

    aliases = {r = "rebase --autostash";};

    extraConfig = {
      core = {
        autocrlf = "input";
        excludesfile = (pkgs.writeText ".gitignore" (builtins.readFile ./global.gitignore)).outPath;
      };

      pull = {rebase = false;};

      init = {defaultBranch = "main";};
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

      vim-yaml
      vim-json
      vim-markdown
    ];
  };
}
