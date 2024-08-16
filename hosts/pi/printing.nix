{ pkgs, ... }: {
  # Printing
  services.printing = {
    enable = true;
    browsing = true;
    listenAddresses = [ "*:631" ];
    allowFrom = [ "all" ];
    defaultShared = true;
    extraConf = ''
      DefaultEncryption Never
    '';
    drivers = [
      pkgs.brlaser
    ];
  };

  networking.firewall.allowedTCPPorts = [
    631 # CUPS
  ];
  networking.firewall.allowedUDPPorts = [
    631 # CUPS
  ];
}
