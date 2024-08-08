{ lib
, config
, ...
}: {
  system.stateVersion = "24.11";
  imports = [
    ./modules/fixup-allow-missing-modules.nix
    ./modules/system.nix
    ./modules/nix-config.nix
    ./modules/printing.nix
    ./modules/network.nix
    ../../nixos/modules/my-networks
    ../../nixos/modules/snowflake
    # ./timecapsule.nix
  ];
}
