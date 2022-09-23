{
  config,
  pkgs,
  ...
}: {
  services.avahi = {
    nssmdns = true;
    enable = true;
    ipv4 = true;
    ipv6 = false;
    publish = {
      enable = true;
      userServices = true;
      addresses = true;
      domain = true;
      hinfo = true;
      workstation = true;
    };
  };

  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
  };

  networking.firewall.enable = true;
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    80
    631 # CUPS
    3478 # STUN for snowflake
  ];
  networking.firewall.allowedUDPPorts = [
    631 # CUPS
    3478 # STUN for snowflake
  ];
}
