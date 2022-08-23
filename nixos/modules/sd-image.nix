{
  modulesPath ? <nixpkgs/nixos/modules>,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # (modulesPath + "/profiles/base.nix")
    # (modulesPath + "/installer/sd-card/sd-image.nix")
    # (modulesPath + "/profiles/installation-device.nix")
    # (modulesPath + "/installer/sd-card/sd-image-raspberrypi.nix")
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

  sdImage = {
    compressImage = false;
    # This might need to be increased when deploying multiple configurations.
    firmwareSize = 128;
    populateRootCommands = "mkdir -p ./files/var/empty";
  };
}
