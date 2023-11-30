{ ... }: {
  nix.linux-builder.enable = true;
  nix.linux-builder.maxJobs = 8;
  # When bootstrapping, comment modules out to use the binary cache version
  nix.linux-builder.config = {
    virtualisation.darwin-builder.diskSize = 60 * 1024;
    virtualisation.darwin-builder.memorySize = 16 * 1024;
  };

  launchd.daemons.linux-builder.serviceConfig.StandardOutPath = "/var/log/linux-builder.log";
  launchd.daemons.linux-builder.serviceConfig.StandardErrorPath = "/var/log/linux-builder.log";
}
