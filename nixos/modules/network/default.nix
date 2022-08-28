{
  config,
  pkgs,
  ...
}: {
  services.avahi = {
    nssmdns = true;
    enable = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
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

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [80];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
