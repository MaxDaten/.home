{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  headless ? true,
  ...
}: let
  darwinPackages = with pkgs; [
    terminal-notifier
  ];

  isDarwin = pkgs.stdenv.isDarwin;

  guiPackages = with pkgs; [
    # https://www.nerdfonts.com/
    (nerdfonts.override
      {
        fonts = [
          "Hack"
          "JetBrainsMono"
          "FiraMono"
          "FiraCode"
        ];
      })
  ];
in
  with lib; {
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "22.11";

    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home.username = "jloos";
    home.homeDirectory =
      if isDarwin
      then "/Users/jloos"
      else "/home/jloos";

    imports = [
      inputs.sops-nix.homeManagerModule
      ./modules/starship.nix
    ];

    sops = {
      defaultSopsFile = ../../secrets/main.yaml;
      age.sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      age.generateKey = true;

      # FIXME: Currently not working
      secrets.OPENAI_API_KEY = {
        path = "${config.home.homeDirectory}/.config/openai/OPENAI_API_KEY";
      };
    };

    home.packages = with pkgs;
      [
        gnupg
        direnv
        htop
        duf

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
        lsd
        fd

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
        nil # Nix Language Server

        # Infrastructure
        awscli2
        google-cloud-sdk
        kubectl
        kustomize
        dive # Analyze docker layer
      ]
      ++ lib.optionals (pkgs.stdenv.isDarwin) darwinPackages
      ++ lib.optionals (!headless) guiPackages;

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    # Configurations
    programs.man.generateCaches = true; # Allow man completions

    home.sessionVariables = {
      EDITOR =
        if pkgs.stdenv.isDarwin
        then "code --wait"
        else "vim";
    };

    programs.ssh.enable = true;
    programs.ssh.matchBlocks = {
      "pi4-nixos" = {
        hostname = "pi4-nixos";
        user = "jloos";
        identitiesOnly = true;
        identityFile = [
          "~/.ssh/id_ed25519"
          "~/.ssh/id_rsa"
        ];
      };

      "maandr" = {
        hostname = "maandr.de";
        user = "root";
      };
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

    programs.fzf = let
      fd = "${pkgs.fd}/bin/fd";
    in {
      enable = true;
      changeDirWidgetCommand = "${fd} --type d --hidden --follow --exclude .git --no-ignore";
      changeDirWidgetOptions = ["--preview 'tree -C {} | head -200'"];
    };

    programs.broot.enable = true;

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

      shellAbbrs = mkMerge [
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
        (mkIf isDarwin {
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
        gpt_functions = import ./fish-functions/gpt.nix;
      in {
        inherit (gpt_functions) hey_gpt data_gpt;
        gitignore = "curl -sL https://www.gitignore.io/api/$argv";
        fish_reload = "source ~/.config/fish/config.fish";
      };
    };

    programs.bat.enable = true;
    programs.bash.enable = true;
    programs.bash.enableCompletion = true;
    programs.zsh.enable = true;
    programs.zsh.enableCompletion = true;

    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    # Git
    programs.git = {
      enable = true;
      userName = "Jan-Philip Loos";
      userEmail = "maxdaten@gmail.com";

      aliases = {
        r = "rebase --autostash";
        # https://softwaredoug.com/blog/2022/11/09/idiot-proof-git-aliases.html
        mainbranch = "!git remote show origin | sed -n '/HEAD branch/s/.*: //p'";
        switch-default = "!git switch $(git mainbranch)";
        sd = "switch-default";
        synced = "!git pull origin $(git mainbranch) --rebase";
        update = "!git pull origin $(git rev-parse --abbrev-ref HEAD) --rebase";
        squash = "!git rebase -v -i $(git mainbranch)";
        publish = "push origin HEAD --force-with-lease";
        pub = "publish";
      };

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
