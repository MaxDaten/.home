{ ... }: {
  nix.linux-builder.enable = true;
  nix.linux-builder.maxJobs = 16;
  # When bootstrapping, comment modules out to use the binary cache version
  nix.linux-builder.modules = [
    (
      { config, ... }: {
        virtualisation.darwin-builder.diskSize = 50 * 1024;
        virtualisation.darwin-builder.memorySize = 4 * 1024;
      }
    )
  ];
  launchd.daemons.linux-builder.serviceConfig.StandardOutPath = "/var/log/linux-builder.log";
  launchd.daemons.linux-builder.serviceConfig.StandardErrorPath = "/var/log/linux-builder.log";
}
