{ pkgs, lib, ... }: {
  # Printing
  services.printing.enable = true;
  services.printing.browsing = true;
  services.printing.listenAddresses = [ "*:631" ];
  services.printing.allowFrom = [ "all" ];
  services.printing.defaultShared = true;
  services.printing.extraConf = ''
    DefaultEncryption Never
  '';
  services.printing.drivers = [
    pkgs.brlaser
  ];
}
