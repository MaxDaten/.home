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

  networking.nftables.firewall = {
    rules.printing = {
      from = [ "local" ];
      to = [ "fw" ];
      allowedTCPPorts = [ 631 ];
      allowedUDPPorts = [ 631 ];
    };
  };
}
