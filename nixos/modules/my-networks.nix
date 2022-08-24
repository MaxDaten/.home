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
    networks = {
      "Player Five" = {
        psk = "XXXX";
      };
    };
  };
}
