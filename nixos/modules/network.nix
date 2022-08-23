{
  modulesPath ? <nixpkgs/nixos/modules>,
  pkgs,
  lib,
  ...
}: {
  networking = {
    hostName = "pi4-nixos";
    # networkmanager = {
    #   enable = true;
    # };
  };
  # Wireless networking (1). You might want to enable this if your Pi is not attached via Ethernet.
  networking.wireless = {
    enable = true;
    interfaces = ["wlan0"];
    networks = {
      "Player Five" = {
        psk = "xxxx";
      };

      "FRITZ!Box 7590 QC" = {
        psk = "xxxx";
      };
    };
  };

  # Wireless networking (2). Enables `wpa_supplicant` on boot.
  systemd.services.wpa_supplicant.wantedBy = lib.mkOverride 10 ["default.target"];

  # NTP time sync.
  services.timesyncd.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
