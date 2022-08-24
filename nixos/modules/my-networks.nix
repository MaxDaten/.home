{
  config,
  pkgs,
  modulesPath,
  ...
}: {
  # Wireless networking (1). You might want to enable this if your Pi is not attached via Ethernet.
  networking.wireless = {
    enable = true;
    interfaces = ["wlan0"];
    environmentFile = ./. + ./wireless-secrets.env;
    networks = {
      "Player Five" = {
        psk = "@PSK_PLAYER_FIVE_TWO@";
        priority = 100;
      };
      "Player Two" = {
        psk = "@PSK_PLAYER_FIVE_TWO@";
        priority = 90;
      };
    };
  };
}
