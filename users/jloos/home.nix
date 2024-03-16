{ config
, lib
, pkgs
, inputs
, headless ? true
, ...
}:
let
  darwinPackages = with pkgs; [
    terminal-notifier
    iterm2
    raycast
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
    then lib.mkForce "/Users/jloos"
    else "/home/jloos";

  imports = [
    inputs.sops-nix.homeManagerModule
    (import ./modules/fish.nix { inherit pkgs config isDarwin lib; })
    ./modules/starship.nix
    ./modules/git.nix
    ./modules/vim.nix
    ./modules/ssh.nix
    ./modules/tmux.nix
    ./modules/programs.nix
    ./modules/fzf.nix
    ./modules/sops.nix
    (import ./modules/heygpt.nix { inherit pkgs config isDarwin lib; })
  ];

  home.packages = with pkgs;
    [
      gnupg
      direnv
      htop
      duf
      xz

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
      #> ERROR: Could not find a version that satisfies the requirement keyring<24.0,>=23.4 (from yubikey-manager) (from versions: none)
      #> ERROR: No matching distribution found for keyring<24.0,>=23.4
      # yubikey-manager

      # Haskell
      haskell-language-server
      ghc

      # Data Structures
      jq
      yq
      jless
      dasel # Query data structures
      gron # transforms to grepable jsons

      # linting
      shellcheck

      # Nix tools
      nixVersions.nix_2_19
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
      lazydocker # k9s for docker
      skopeo # inspect docker images without docker daemon
      (import (fetchTarball {
        url = "https://install.devenv.sh/latest";
        sha256 = "sha256:0wj5455mk0kgm4vnvqia6x4qhkwwf3cn07pdsd4wmfdbp9rxr44a";
      })).packages.${pkgs.stdenv.system}.default
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

  home.stateVersion = "23.05";
  home.sessionVariables = {
    EDITOR =
      if pkgs.stdenv.isDarwin
      then "code --wait"
      else "vim";
  };
}
