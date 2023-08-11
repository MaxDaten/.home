{...}: {
  nix.linux-builder.enable = true;
  nix.linux-builder.maxJobs = 4;
  nix.linux-builder.modules = [
    (
      {config, ...}: {
        virtualisation.darwin-builder.diskSize = 40 * 1024;
        virtualisation.darwin-builder.memorySize = 4 * 1024;
      }
    )
  ];
  launchd.daemons.linux-builder.serviceConfig.StandardOutPath = "/var/log/linux-builder.log";
  launchd.daemons.linux-builder.serviceConfig.StandardErrorPath = "/var/log/linux-builder.log";
}
