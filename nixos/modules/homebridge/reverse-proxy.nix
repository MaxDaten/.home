{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  homebridgeUriPath = "/homebridge/";
  cfg = config.services.homebridge;
in {
  # nginx reverse proxy
  services.nginx.virtualHosts."homebridge.pi4-nixos.local" = mkIf cfg.enable {
    locations."${homebridgeUriPath}" = {
      proxyPass = "http://127.0.0.1:${toString cfg.uiPort}/";
      proxyWebsockets = true;
    };
  };
}
