{ modulesPath
, ...
}: {
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix")
  ];

  sdImage = {
    compressImage = false;
    # /boot partition
    # This might need to be increased when deploying multiple configurations.
    firmwareSize = 1024;
    populateRootCommands = "mkdir -p ./files/var/empty";
  };
}
