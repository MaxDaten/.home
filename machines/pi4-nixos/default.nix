{ nixos-hardware
, lib
, config
, ...
}: {
  system.stateVersion = "23.11";
  imports = [
    ./fixup-allow-missing-modules.nix
    nixos-hardware.nixosModules.raspberry-pi-4
    ./timecapsule.nix
  ];

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

    "/mnt/timecapsule" = {
      label = "TIMECAPSULE";
      options = [ "uid=${config.users.groups.timecapsule.uid},gid=${config.users.groups.timecapsule.gid}" ];
    };
  };

  networking = {
    hostName = "pi4-nixos";
    # networkmanager = {
    #   enable = true;
    # };
  };

  # Wireless networking (2). Enables `wpa_supplicant` on boot.
  systemd.services.wpa_supplicant.wantedBy = lib.mkOverride 10 [ "default.target" ];

  # NTP time sync.
  services.timesyncd.enable = true;

  # Virtualisation, enable emulation of other systems
  virtualisation.libvirtd.enable = true;
  security.polkit.enable = true;

  # Allow remote nix
  services.openssh.settings.PermitRootLogin = "yes";
  # Nix System
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      max-jobs = 4;
      cores = 4;
      system-features = [ "kvm" "nixos-test" "benchmark" "big-parallel" ];
      extra-platforms = [ "x86_64-linux" ];
      trusted-users = [ "root" "jloos" "@wheel" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
      keep-outputs = true
      keep-derivations = true
    '';
  };
}
