{ config
, pkgs
, modulesPath
, ...
}: {
  sops.secrets."wireless.env" = {
    neededForUsers = true;
  };

  # Wireless networking (1). You might want to enable this if your Pi is not attached via Ethernet.
  networking.wireless = {
    enable = true;
    interfaces = [ "wlan0" ];
    secretsFile = config.sops.secrets."wireless.env".path;
    networks = {
      "Player Five" = {
        pskRaw = "ext:PLAYER_FIVE";
        priority = 100;
      };
      "Player Two" = {
        pskRaw = "ext:PLAYER_TWO";
        priority = 50;
      };
    };
  };
}
