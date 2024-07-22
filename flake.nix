{
  description = "Personal NixOS configuration";

  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
  
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixos-darwin";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";
    vscode-server.url = "github:msteen/nixos-vscode-server";
    nil.url = "github:oxalica/nil";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell.url = "github:numtide/devshell";
  };

  outputs =
    { self
    , nixpkgs
    , nixos
    , nixos-darwin
    , darwin
    , nixos-hardware
    , flake-utils
    , vscode-server
    , home-manager
    , sops-nix
    , devshell
    , nil
    ,
    } @ inputs:
    let
      inherit (self) outputs;
      devShells = flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;

            overlays = [
              devshell.overlays.default
            ];
          };
        in
        {
          devShells.default = pkgs.devshell.mkShell {
            packages = with pkgs; [
              sops
              age
              ssh-to-age
              age

              stress
              speedtest-cli

              node2nix
              rsync
              nil.packages.${system}.default
              nixpkgs-fmt
            ];

            env = [
              {
                name = "SOPS_AGE_KEY_FILE";
                eval = "$HOME/.config/sops/age/keys.txt";
              }
              {
                name = "SOPS_AGE_KEY_DIRECTORY";
                eval = "$HOME/.config/sops/age";
              }
            ];
          };
        });
    in
    {
      # scutil --get LocalHostName
      darwinConfigurations."MacBook-Pro" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs outputs;
        };
        modules = [
          ./machines/macos/configuration.nix
          ./machines/macos/modules/linux-builder.nix
          ./nixos/modules/build-machines.nix

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs outputs;
              headless = false;
            };
            home-manager.users.jloos = import ./users/jloos/home.nix;
          }
        ];
      };

      nixosConfigurations.pi4-nixos = nixos.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit nixos-hardware;
        };
        modules = [
          ./machines/pi4-nixos
          ./nixos/modules/pi4-sd-image.nix
          ./nixos/modules/system.nix
          ./nixos/modules/network
          ./nixos/modules/my-networks
          ./nixos/modules/build-machines.nix
          # Secret Management
          sops-nix.nixosModules.sops
          {
            sops.defaultSopsFile = ./secrets/pi4-nixos.yaml;
            sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
            sops.age.keyFile = "/var/lib/sops-nix/key.txt";
            sops.age.generateKey = true;
          }

          ./nixos/modules/system-dashboard
          # ./nixos/modules/homebridge
          # {
          #   services.homebridge.enable = true;
          #   services.homebridge.openFirewall = true;
          # }

          # User environment managed by Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs outputs;
              headless = true;
            };
          }
          (import ./users/jloos)

          vscode-server.nixosModule
          (
            { config
            , pkgs
            , ...
            }: {
              services.vscode-server.enable = true;
              services.vscode-server.nodejsPackage = pkgs.nodejs_20;
            }
          )

          ./nixos/modules/snowflake
        ];
      };

      packages.aarch64-linux = {
        default = self.nixosConfigurations.pi4-nixos.config.system.build.sdImage;
      };
    }
    // devShells;
}
