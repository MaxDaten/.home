{
  config,
  pkgs,
  ...
}: let
  prometheusUriPath = "/prometheus/";
in {
  services.prometheus.enable = true;
  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [
          "systemd"
          "processes"
          "meminfo_numa"
          "time"
          "hwmon"
          "powersupplyclass"
          "pressure"
          "loadavg"
        ];
        port = 9092;
      };
    };

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
          }
        ];
      }
    ];
  };

  services.avahi.extraServiceFiles.prometheus = ''
    <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
    <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
    <service-group>
      <name replace-wildcards="yes">Prometheus on %h</name>
      <service>
        <type>_http._tcp</type>
        <port>${toString config.services.prometheus.port}</port>
      </service>
    </service-group>
  '';

  # nginx reverse proxy
  services.nginx.virtualHosts."prometheus.pi4-nixos.local" = {
    locations."${prometheusUriPath}" = {
      proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}/";
      proxyWebsockets = true;
    };
  };
}
