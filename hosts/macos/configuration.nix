{ pkgs, ... }: {
  # https://daiderd.com/nix-darwin/manual/index.html
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.fish
    pkgs.git
  ];


  nix.settings.substituters = [
    "https://cache.nixos.org/"
    "https://cache.nixos.org/"
    "https://briendsgmbh.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    # setup authtoken via `cachix authtoken <token>`
    "briendsgmbh.cachix.org-1:gJT1XP1/F3dNEwqyWOBsZ11uFKTvDKaMQA/dFhs/ywE="
  ];
  nix.settings.trusted-users = [
    "root"
    "@admin"
  ];
  nix.configureBuildUsers = true;

  nix.package = pkgs.nix;
  # Enable experimental nix command and flakes
  nix.settings = {
    experimental-features = "nix-command flakes repl-flake auto-allocate-uids auto-allocate-uids";
    auto-optimise-store = false;
    keep-outputs = true;
    keep-derivations = true;
    warn-dirty = false;
    build-users-group = "nixbld";
    builders-use-substitutes = true;
    allow-import-from-derivation = true;
  };
  # nix.settings.extra-platforms = lib.optionalString (pkgs.system == "aarch64-darwin") "x86_64-darwin aarch64-darwin";

  # init nix in zsh & fish
  # programs.zsh.enable = true;
  programs.fish.enable = true;
  environment.shells = with pkgs; [ bashInteractive fish zsh ];
  environment.loginShell = "${pkgs.fish}/bin/fish --login";
  environment.variables.LANG = "en_US.UTF-8";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  programs.nix-index.enable = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;
}