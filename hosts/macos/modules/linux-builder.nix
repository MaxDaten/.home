{ ... }: {
  # sudo launchctl kickstart -k system/org.nixos.linux-builder
  # https://github.com/LnL7/nix-darwin/blob/master/modules/nix/linux-builder.nix
  nix.linux-builder = {
    enable = true;
    ephemeral = true;
    systems = [ "x86_64-linux" ];
    # When bootstrapping, comment modules out to use the binary cache version
    config = ({ ... }: {
      nixpkgs.hostPlatform = "x86_64-linux";
      virtualisation.cores = 10;
      # # https://github.com/NixOS/nixpkgs/blob/master/doc/packages/darwin-builder.section.md#darwinlinux-builder-sec-darwin-builder
      virtualisation.darwin-builder.diskSize = 60 * 1024;
      virtualisation.darwin-builder.memorySize = 16 * 1024;
    });
  };

  launchd.daemons.linux-builder.serviceConfig.StandardOutPath =
    "/var/log/linux-builder.log";
  launchd.daemons.linux-builder.serviceConfig.StandardErrorPath =
    "/var/log/linux-builder.log";
}
