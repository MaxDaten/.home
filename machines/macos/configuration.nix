{ pkgs, ... }: {
  # https://daiderd.com/nix-darwin/manual/index.html
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.fish
  ];

  environment.loginShell = pkgs.fish;

  nix.settings.substituters = [
    "https://cache.nixos.org/"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
  nix.settings.trusted-users = [
    "root"
    "@admin"
  ];
  nix.configureBuildUsers = true;

  nix.package = pkgs.nixVersions.nix_2_19;
  # Enable experimental nix command and flakes
  nix.settings.experimental-features = "nix-command flakes repl-flake auto-allocate-uids auto-allocate-uids";
  nix.settings.auto-optimise-store = true;
  nix.settings.keep-outputs = true;
  nix.settings.keep-derivations = true;
  nix.settings.warn-dirty = false;
  nix.settings.build-users-group = "nixbld";
  nix.settings.builders-use-substitutes = true;
  nix.settings.allow-import-from-derivation = true;
  # nix.settings.extra-platforms = lib.optionalString (pkgs.system == "aarch64-darwin") "x86_64-darwin aarch64-darwin";

  # init nix in zsh & fish
  programs.zsh.enable = true;
  programs.fish.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  programs.nix-index.enable = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;
}
