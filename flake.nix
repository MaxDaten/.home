{
  description = "Personal NixOS configuration";

  inputs =
    {
      devenv-root = {
        url = "file+file:///dev/null";
        flake = false;
      };

      # Nix Derivations
      nixos.url = "github:NixOS/nixpkgs/nixos-24.05";
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      nixos-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";


      darwin = {
        url = "github:lnl7/nix-darwin";
        inputs.nixpkgs.follows = "nixos-darwin";
      };

      flake-parts.url = "github:hercules-ci/flake-parts";

      # System Tools
      nixos-hardware.url = "github:NixOS/nixos-hardware/master";
      home-manager = {
        url = "github:nix-community/home-manager/release-24.05";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      sops-nix = {
        url = "github:Mic92/sops-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      # Development environment
      devenv.url = "github:cachix/devenv";
      nix2container = {
        url = "github:nlewo/nix2container";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      vscode-server.url = "github:msteen/nixos-vscode-server";
      nil.url = "github:oxalica/nil";
    };

  outputs =
    { self
    , nixos
    , nixpkgs
    , nixos-darwin
    , darwin
    , flake-parts
    , nixos-hardware
    , home-manager
    , sops-nix
    , devenv
    , nil
    , vscode-server
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {

        devenv.shells.default = {
          devenv.root =
            let
              devenvRootFileContent = builtins.readFile inputs.devenv-root.outPath;
            in
            pkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;
          
          name = ".home shell";
          
          imports = [ ];

          packages = [
          ];
        };
      };

      flake = {

        packages = {
          aarch64-linux = {
            pi4-nixos-sd-image = self.nixosConfigurations.pi4-nixos.config.system.build.sdImage;
            default = self.nixosConfigurations.pi4-nixos-sd-image;
          };
        };

        apps = { };

        #   # scutil --get LocalHostName
        darwinConfigurations = {
          "MacBook-Pro" = darwin.lib.darwinSystem {
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
        };

        nixosConfigurations = {
          pi4-nixos = nixos.lib.nixosSystem {
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
        };

        homeManagerModules = { };
      };
    };

  #   packages = {
  #     aarch64-linux =
  #       {
  #         default = self.nixosConfigurations.pi4-nixos.config.system.build.sdImage;
  #       };
  #   };
  # }
  # // devShells;
}
