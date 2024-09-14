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
    secretsFile = config.sops.secrets."wireless.env".path;
    networks = {
      "Player Five" = {
        psk = "ext:PLAYER_FIVE";
        priority = 100;
      };
      "Player Two" = {
        psk = "ext:PLAYER_TWO";
        priority = 50;
      };
    };
  };
}
