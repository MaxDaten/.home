{ pkgs, config, ... }: {
  # https://daiderd.com/nix-darwin/manual/index.html
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = 5;
  ids.gids.nixbld = 350;

  environment.systemPackages = with pkgs; [ fish git cachix mas ];

  nix.settings.substituters =
    [ "https://cache.nixos.org/" "https://maxdaten-io.cachix.org" ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    # setup authtoken via `cachix authtoken <token>`
    "maxdaten-io.cachix.org-1:ZDDi/8gGLSeUEU9JST6uXDcQfNp2VZzccmjUljPHHS8="
  ];
  nix.settings.trusted-users = [ "root" "@admin" ];

  nix.package = pkgs.nix;
  # Enable experimental nix command and flakes
  nix.settings = {
    experimental-features =
      "nix-command flakes auto-allocate-uids auto-allocate-uids";
    auto-optimise-store = false;
    keep-outputs = true;
    keep-derivations = true;
    warn-dirty = false;
    build-users-group = "nixbld";
    builders-use-substitutes = true;
    allow-import-from-derivation = true;
    download-buffer-size = 2000000000; # 2 GB
  };
  # nix.settings.extra-platforms = lib.optionalString (pkgs.system == "aarch64-darwin") "x86_64-darwin aarch64-darwin";

  # init nix in zsh & fish
  programs.fish.enable = true;
  environment.shells = with pkgs; [ bashInteractive fish zsh ];
  environment.loginShellInit = ''
    export PATH=$HOME/.local/bin:$PATH
  '';
  environment.variables.LANG = "en_US.UTF-8";

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  services.ollama.enable = true;
}
