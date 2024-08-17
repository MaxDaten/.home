{ pkgs, ... }:

let
  subnet-mask = "255.255.255.0";
  subnet = "192.168.178.0/24";
in
{

  networking.hostName = "pi";

  services.avahi = {
    enable = true;
    nssmdns4 = true;
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

  services.snowflake-proxy.enable = true;
  services.snowflake-proxy.capacity = 32;

  networking.firewall = {
    allowedTCPPorts = [ 80 433 ];
  };

  # add nft to systemPackages
  environment.systemPackages = with pkgs; [
    nftables
  ];

  # Zone Based NF Firewall
  # https://thelegy.github.io/nixos-nftables-firewall/
  networking.nftables.firewall = {
    enable = true;
    snippets.nnf-common.enable = true;
    zones.uplink = {
      interfaces = [ "end0" "wlan0" ];
    };
    zones.local = {
      parent = "uplink";
      ipv4Addresses = [ subnet ];
    };

    rules.snowflake-proxy = {
      from = "all";
      to = [ "fw" ];
      # Stun and Turn
      allowedUDPPorts = [ 3478 5349 ];
      allowedTCPPorts = [ 3478 5349 ];
      allowedUDPPortRanges = [
        { from = 32768; to = 60999; }
      ];
    };
  };

  # ssh only from local
  networking.nftables.firewall.rules.private-ssh = {
    from = [ "local" ];
    to = [ "fw" ];
    allowedTCPPorts = [ 22 ];
  };


}
