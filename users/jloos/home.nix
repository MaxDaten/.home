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
      ./modules/git.nix
      (import ./modules/fish.nix {inherit pkgs config isDarwin lib;})
      ./modules/vim.nix
      ./modules/ssh.nix
      ./modules/tmux.nix
      ./modules/programs.nix
      ./modules/fzf.nix
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
  }
