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
    iterm2
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
          "Terminus"
        ];
      })
  ];
in
  with lib; {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home.username = "jloos";
    home.homeDirectory =
      if isDarwin
      then "/Users/jloos"
      else "/home/jloos";

    imports = [
      inputs.sops-nix.homeManagerModule
      (import ./modules/fish.nix {inherit pkgs config isDarwin lib;})
      ./modules/starship.nix
      ./modules/git.nix
      ./modules/vim.nix
      ./modules/ssh.nix
      ./modules/tmux.nix
      ./modules/programs.nix
      ./modules/fzf.nix
      ./modules/sops.nix
      (import ./modules/heygpt.nix {inherit pkgs config isDarwin lib;})
    ];

    home.packages = with pkgs;
      [
        gnupg
        direnv
        htop
        duf

        peco
        gh

        # shell tools
        spaceship-prompt
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

    programs.btop.enable = true;
    # https://github.com/aristocratos/btop#configurability
    programs.btop.settings = {
      # truecolor = !isDarwin;
    };

    home.stateVersion = "22.11";
    home.sessionVariables = {
      EDITOR =
        if pkgs.stdenv.isDarwin
        then "code --wait"
        else "vim";
    };
  }
