{ ... }: {
  nix.linux-builder.enable = true;
  nix.linux-builder.maxJobs = 8;
  # When bootstrapping, comment modules out to use the binary cache version
  nix.linux-builder.config = ({pkgs, ...}: {
    # https://github.com/NixOS/nixpkgs/blob/master/doc/packages/darwin-builder.section.md#darwinlinux-builder-sec-darwin-builder
    virtualisation.darwin-builder.diskSize = 60 * 1024;
    virtualisation.darwin-builder.memorySize = 16 * 1024;
  });

  launchd.daemons.linux-builder.serviceConfig.StandardOutPath = "/var/log/linux-builder.log";
  launchd.daemons.linux-builder.serviceConfig.StandardErrorPath = "/var/log/linux-builder.log";
}