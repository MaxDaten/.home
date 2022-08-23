{
  modulesPath,
  pkgs,
  lib,
  ...
}: {
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

  sdImage = {
    compressImage = false;
    # This might need to be increased when deploying multiple configurations.
    firmwareSize = 128;
    populateRootCommands = "mkdir -p ./files/var/empty";
  };
}
