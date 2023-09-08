# Following: https://github.com/SamirHafez/config/blob/ef14103d4fb31d9e95264b05c78b57a1201b3c65/pi/modules/homebridge.nix
{ config
, pkgs
, lib
, ...
}:
with lib; let
  cfg = config.services.homebridge;
  # https://github.com/oznu/homebridge-config-ui-x/wiki/Manual-Configuration
  configFile = builtins.toFile "config.json" (builtins.toJSON {
    bridge = {
      name = "Homebridge 2D83";
      username = "0E:DE:6C:64:2D:83";
      port = cfg.bridgePort;
      pin = "906-88-561";
      advertiser = "avahi";
    };
    platforms = [
      {
        platform = "config";
        name = "Config";
        port = cfg.uiPort;
        sudo = false; # prevent upgrading of plugins & homebridge because we want to be pure
        proxyHost = "pi4-nixos.local:${toString cfg.uiPort}";
        tempUnits = "c";
        # log = {
        #   method = "systemd";
        #   service = "homebridge";
        # };
      }
    ];
  });

  homebridge-packages = pkgs.symlinkJoin {
    name = "homebridge-all";
    paths = builtins.attrValues (import ./package { inherit pkgs; });
  };
in
{
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

      uiPort = mkOption {
        type = types.int;
        default = 8581;
        description = ''
          Ports used by homebridge web ui.
        '';
      };

      bridgePort = mkOption {
        type = types.int;
        default = 51766;
        description = ''
          Ports used by homebridge for homekit integration.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    users.users.homebridge = {
      group = "homebridge";
      home = cfg.workDir;
      createHome = true;
      extraGroups = [ "wheel" ];
      isSystemUser = true;
    };
    users.groups.homebridge = { };

    systemd.services.homebridge = {
      description = "Homebridge Service";
      wants = [ "network-online.target" ];
      after = [ "syslog.target" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      path = [
        pkgs.nodejs
        pkgs.bash
        pkgs.coreutils
        homebridge-packages
      ];

      environment = {
        # UIX_CUSTOM_PLUGIN_PATH="${homebridge-packages}/lib/node_modules"
        UIX_STORAGE_PATH = cfg.workDir;
        UIX_INSECURE_MODE = "1";
        DEBUG = "*";

        HOMEBRIDGE_CONFIG_UI_TERMINAL = "1";
        DISABLE_OPENCOLLECTIVE = "true";
        HOMEBRIDGE_OPTS = "--insecure --debug --user-storage-path ${cfg.workDir}";
        # We need to prevent homebridge to try to resolve plugins in a impure way
        # https://github.com/homebridge/homebridge/blob/master/src/pluginManager.ts#L480
        NODE_PATH = "${homebridge-packages}/lib/node_modules";
      };

      preStart = ''
        rm -f "${cfg.workDir}/config.json"
        ln -s ${configFile} "${cfg.workDir}/config.json"
      '';

      script = ''
        printenv
        echo $PATH | tr ':' '\n'
        homebridge $HOMEBRIDGE_OPTS
      '';

      # Adoption of linux installer:
      # https://github.com/oznu/homebridge-config-ui-x/blob/master/src/bin/platforms/linux.ts#L689
      serviceConfig = {
        Type = "simple";
        User = "homebridge";
        Group = "homebridge";

        WorkingDirectory = cfg.workDir;
        Restart = "always";
        RestartSec = 3;
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.uiPort
        cfg.bridgePort
      ];
      allowedUDPPorts = [
        cfg.uiPort
      ];
    };
  };
}
