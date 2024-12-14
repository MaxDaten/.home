{ config, lib, pkgs, inputs, headless ? true, ... }:
let
  darwinPackages = with pkgs; [
    terminal-notifier
    iterm2
    raycast
    # wireshark # broken on darwin https://github.com/NixOS/nixpkgs/issues/362416
  ];

  isDarwin = pkgs.stdenv.isDarwin;

  guiPackages = with pkgs; [
    # https://www.nerdfonts.com/
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/fonts/nerd-fonts/manifests/fonts.json
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    nerd-fonts.zed-mono
    warp-terminal
    zed-editor
  ];
in {
  home.stateVersion = "24.05";
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jloos";
  home.homeDirectory =
    if isDarwin then lib.mkForce "/Users/jloos" else "/home/jloos";

  imports = [
    inputs.nix-index-database.hmModules.nix-index
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
  ];

  home.file.warp-themes = lib.mkIf (!headless) {
    target = ".warp/themes";
    recursive = true;
    source = builtins.fetchGit {
      url = "https://github.com/warpdotdev/themes.git";
      ref = "main";
      rev = "2a25630d59a6c4f2673f1e5156d2bf29ba6a9190";
    };
  };

  programs.nix-index-database.comma.enable = true;

  home.packages = with pkgs;
    [
      gnupg
      direnv
      htop
      duf
      xz

      peco
      gh
      git-ignore
      lazygit

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
      rename
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
      nixfmt
      # alejandra
      nil # Nix Language Server
      nixd

      # Infrastructure
      # awscli2 # currently broken
      google-cloud-sdk
      kubectl
      kustomize
      dive # Analyze docker layer
      lazydocker # k9s for docker
      skopeo # inspect docker images without docker daemon
      (import (fetchTarball {
        url = "https://install.devenv.sh/latest";
        sha256 = "sha256:03bc61v6k49wf74yk68da35jff03qmvsm72b53mvs89cmffn868n";
      })).packages.${pkgs.stdenv.system}.default
    ] ++ lib.optionals (pkgs.stdenv.isDarwin) darwinPackages
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

  home.sessionVariables = {
    EDITOR = if pkgs.stdenv.isDarwin then "zeditor --wait" else "vim";
  };
}
