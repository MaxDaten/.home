{ config
, pkgs
, modulesPath
, ...
}: {
  sops.secrets."wireless.env" = { };

  # Wireless networking (1). You might want to enable this if your Pi is not attached via Ethernet.
  networking.wireless = {
    enable = true;
    interfaces = [ "wlan0" ];
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
}
