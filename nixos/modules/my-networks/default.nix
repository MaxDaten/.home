{
  config,
  pkgs,
  modulesPath,
  ...
}: {
  sops.secrets."wireless.env" = {};

  # Wireless networking (1). You might want to enable this if your Pi is not attached via Ethernet.
  networking.wireless = {
    enable = true;
    interfaces = ["wlan0"];
    environmentFile = "/run/secrets/wireless.env";
    networks = {
      "Player Five" = {
        psk = "@PLAYER_FIVE@";
        priority = 100;
      };
      "Player Two" = {
        psk = "@PLAYER_TWO@";
        priority = 50;
      };
    };
  };

  nix.buildMachines = [
    {
      hostName = "nixbuilder.qwiz.buzz";
      system = "x86_64-linux";
      maxJobs = 4;
      speedFactor = 2;
      supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
    }
  ];
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
