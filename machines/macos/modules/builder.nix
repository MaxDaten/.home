{inputs, ...}: let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;
  system = "aarch64-darwin";
  pkgs = nixpkgs.legacyPackages."${system}";
  linuxSystem = builtins.replaceStrings ["darwin"] ["linux"] system;

  darwin-builder = nixpkgs.lib.nixosSystem {
    system = linuxSystem;
    modules = [
      "${nixpkgs}/nixos/modules/profiles/macos-builder.nix"
      {
        virtualisation.host.pkgs = pkgs;
        virtualisation.diskSize = lib.mkForce (40 * 1024);
        virtualisation.memorySize = lib.mkForce (4 * 1024);
        system.nixos.revision = lib.mkForce null;
      }
    ];
  };
  # Set to false if you need to bootstrap first
  enableDarwinBuilder = true;
  # Following this guide: https://nixos.org/manual/nixpkgs/unstable/#sec-darwin-builder
  # In short:
  # 1. nix run nixpkgs#darwin.linux-builder
  # 2. Add /etc/ssh/sshd_config.d/100-linux-builder.conf
  # ```
  # Host linux-builder
  #   Hostname localhost
  #   HostKeyAlias linux-builder
  #   Port 31022
  # ```
  # 3. `nix.conf` should be already correct via `nix.buildMachines` setting below
in {
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      protocol = "ssh-ng";
      hostName = "linux-builder";
      sshUser = "builder";
      system = linuxSystem;
      maxJobs = 4;
      supportedFeatures = ["kvm" "benchmark" "big-parallel"];
      sshKey = "/etc/nix/builder_ed25519";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpCV2N4Yi9CbGFxdDFhdU90RStGOFFVV3JVb3RpQzVxQkorVXVFV2RWQ2Igcm9vdEBuaXhvcwo=";
    }
  ];

  launchd.daemons.darwin-builder = lib.mkIf enableDarwinBuilder {
    command = "${darwin-builder.config.system.build.macos-builder-installer}/bin/create-builder";
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/var/log/darwin-builder.log";
      StandardErrorPath = "/var/log/darwin-builder.log";
      WorkingDirectory = "/etc/nix/";
    };
  };
}
