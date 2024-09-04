_: {
  imports = [
    ./configuration.nix
    ./modules/linux-builder.nix
    ./modules/homebrew.nix
    ../../nixos/modules/build-machines.nix
  ];
}
