{
  description = "Raspberry Pi NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixos-hardware.url = github:NixOS/nixos-hardware/master;
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.vscode-server.url = "github:msteen/nixos-vscode-server";
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.sops-nix = {
    url = github:Mic92/sops-nix;
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    flake-utils,
    vscode-server,
    home-manager,
    sops-nix,
  }: let
    system = "aarch64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    devShells = flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          sops
          age
          ssh-to-age
          dig

          stress
          speedtest-cli

          node2nix
        ];
      };
    });
  in
    {
      nixosConfigurations.pi4-nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit nixos-hardware;
        };
        modules = [
          ./machines/pi4-nixos
          ./users/jloos
          ./nixos/modules/pi4-sd-image.nix
          ./nixos/modules/system.nix
          ./nixos/modules/network
          ./nixos/modules/my-networks
          # Secret Management
          sops-nix.nixosModules.sops
          {
            sops.defaultSopsFile = ./secrets/pi4-nixos.yaml;
            sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
            sops.age.keyFile = "/var/lib/sops-nix/key.txt";
            sops.age.generateKey = true;
          }

          ./nixos/modules/system-dashboard
          ./nixos/modules/homebridge
          {
            services.homebridge.enable = false;
            services.homebridge.openFirewall = true;
          }

          # User environment managed by Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              headless = true;
            };
            home-manager.users.jloos = {
              imports = [(./. + "/users/jloos/home.nix")];
            };
          }
        ];
      };

      packages.aarch64-linux.default = self.nixosConfigurations.pi4-nixos.config.system.build.sdImage;
    }
    // devShells;
}
