{
  config,
  pkgs,
  ...
}: let
  grafanaUriPath = "/dashboard/";
in {
  sops.secrets.grafana_admin_password = {
    owner = "grafana";
  };

  services.avahi.extraServiceFiles.grafana = ''
    <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
    <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
    <service-group>
      <name replace-wildcards="yes">Grafana on %h</name>
      <service>
        <type>_http._tcp</type>
        <port>3000</port>
      </service>
    </service-group>
  '';

  # grafana configuration
  services.grafana = {
    enable = true;
    port = 3000;
    addr = "127.0.0.1";
    rootUrl = "%(protocol)s://%(domain)s:%(http_port)s${grafanaUriPath}";

    security = {
      adminUser = "jloos";
      adminPasswordFile = "/run/secrets/grafana_admin_password";
    };
  };

  # nginx reverse proxy
  services.nginx.virtualHosts."grafana.pi4-nixos.local" = {
    locations."${grafanaUriPath}" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}/";
      proxyWebsockets = true;
    };
  };
}
