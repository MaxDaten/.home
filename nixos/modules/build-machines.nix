{ pkgs, ... }: {

  nix.buildMachines = [
    # {
    #   hostName = "hydra.m.briends.cloud";
    #   system = "x86_64-linux";
    #   sshUser = "jloos";
    #   sshKey = "/Users/jloos/.ssh/id_rsa";
    #   publicHostKey =
    #     let
    #       hostkey = ./hydra.m.briends.cloud.pub;
    #       encoded = pkgs.runCommandLocal "base64_encoded_hostkey" { } ''
    #         ${pkgs.libb64}/bin/base64 -e ${hostkey} $out;
    #       '';
    #     in
    #     "${builtins.readFile encoded}";
    #   maxJobs = 4;
    #   speedFactor = 2;
    #   supportedFeatures = [
    #     "nixos-test"
    #     "benchmark"
    #     "big-parallel"
    #     "kvm"
    #   ];
    # }
  ];
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
