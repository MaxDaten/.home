# Following: https://github.com/SamirHafez/config/blob/ef14103d4fb31d9e95264b05c78b57a1201b3c65/pi/modules/homebridge.nix
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.services.homebridge;
  # https://github.com/oznu/homebridge-config-ui-x/wiki/Manual-Configuration
  configFile = builtins.toFile "config.json" (builtins.toJSON {
    platforms = {
      platform = "nixos";
      name = "homebridge for nixos";
      port = cfg.port;
      sudo = false; # prevent upgrading of plugins & homebridge because we want to be pure
      log = {
        method = "systemd";
        service = "homebridge";
      };
    };
  });

  homebridge-packages = pkgs.symlinkJoin {
    name = "homebridge-all";
    paths = builtins.attrValues (import ./package {inherit pkgs;});
  };
in {
  options = {
    services.homebridge = {
      enable = mkEnableOption "Homebridge Server";

      workDir = mkOption {
        type = types.str;
        default = "/var/lib/homebridge";
        description = ''
          The directory where Homebridge stores its data files.
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Open ports in the firewall for the server.
        '';
      };

      port = mkOption {
        type = types.int;
        default = 8581;
        description = ''
          Ports used by homebridge web ui.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    users.users.homebridge = {
      group = "homebridge";
      home = cfg.workDir;
      createHome = true;
      extraGroups = ["wheel"];
      isSystemUser = true;
    };
    users.groups.homebridge = {};

    systemd.services.homebridge = {
      description = "Homebridge Service";
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      path = [
        pkgs.nodejs
        pkgs.bash
      ];

      preStart = let
        copyConfig = ''
          rm -f "${cfg.workDir}/config.json"
          ln -s ${configFile} "${cfg.workDir}/config.json"
        '';
      in
        copyConfig;

      serviceConfig = {
        Type = "forking";
        User = "homebridge";
        Group = "homebridge";

        WorkingDirectory = cfg.workDir;
        ExecStart = "/run/wrappers/bin/sudo ${homebridge-packages}/bin/hb-service start";
        ExecReload = "/run/wrappers/bin/sudo ${homebridge-packages}/bin/hbq-service restart";
        ExecStop = "/run/wrappers/bin/sudo ${homebridge-packages}/bin/hb-service stop";
        # StandardOutput = "append:${cfg.workDir}/logs.log";
        # StandardError = "append:${cfg.workDir}/logs.log";

        KillSignal = "SIGQUIT";
        Restart = "on-failure";
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.port 51373];
      allowedUDPPorts = [cfg.port];
    };
  };
}
