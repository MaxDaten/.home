{
  config,
  pkgs,
  ...
}: {
  # grafana configuration
  services.grafana = {
    enable = true;
    # domain = "grafana.local";
    port = 3000;
    addr = "127.0.0.1";
  };

  # nginx reverse proxy
  # services.nginx.virtualHosts.${config.services.grafana.domain} = {
  services.nginx.virtualHosts."pi4-nixos.local" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
      proxyWebsockets = true;
    };
  };
}
