{ inputs, ... }: {
  imports = [
    inputs.vscode-server.nixosModule
    inputs.sops-nix.nixosModules.sops
    ./configuration.nix
    ./pi-config.nix
    ./network.nix
    ./printing.nix
    ./nix-config.nix
    ./vscode-server.nix
    ../../nixos/modules/my-networks
    ../../nixos/modules/snowflake

    # ./nixos/modules/homebridge
    # {
    #   services.homebridge.enable = true;
    #   services.homebridge.openFirewall = true;
    # }
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
}
