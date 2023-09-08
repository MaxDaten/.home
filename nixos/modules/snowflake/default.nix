# Following: https://blog.tokudan.de/tor-snowflake-on-nixos
{ config
, pkgs
, ...
}: {
  # sudo machinectl shell snowflake $(which journalctl) -fu snowflake
  # systemctl status container@snowflake.service
  containers.snowflake = {
    autoStart = true;
    ephemeral = true;
    config = {
      systemd.services.snowflake = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          IPAccounting = "yes";
          ExecStart = "${pkgs.snowflake}/bin/proxy";
          DynamicUser = "yes";
          # Read-only filesystem
          ProtectSystem = "strict";
          PrivateDevices = "yes";
          ProtectKernelTunables = "yes";
          ProtectControlGroups = "yes";
          ProtectHome = "yes";
          # Deny access to as many things as possible
          NoNewPrivileges = "yes";
          PrivateUsers = "yes";
          LockPersonality = "yes";
          MemoryDenyWriteExecute = "yes";
          ProtectClock = "yes";
          ProtectHostname = "yes";
          ProtectKernelLogs = "yes";
          ProtectKernelModules = "yes";
          RestrictAddressFamilies = "AF_INET AF_INET6";
          RestrictNamespaces = "yes";
          RestrictRealtime = "yes";
          RestrictSUIDSGID = "yes";
          SystemCallArchitectures = "native";
          SystemCallFilter = "~@chown @clock @cpu-emulation @debug @module @mount @obsolete @raw-io @reboot @setuid @swap @privileged @resources";
          CapabilityBoundingSet = "";
          ProtectProc = "invisible";
          ProcSubset = "pid";
        };
      };
    };
  };
}
