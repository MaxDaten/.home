{
  modulesPath ? <nixpkgs/nixos/modules>,
  pkgs,
  lib,
  ...
}: {
  fileSystems = lib.mkForce {
    # There is no U-Boot on the Pi 4, thus the firmware partition needs to be mounted as /boot.
    "/boot" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
}
