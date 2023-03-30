{
  description = "Raspberry Pi NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.vscode-server.url = "github:msteen/nixos-vscode-server";
  inputs.nil.url = "github:oxalica/nil";
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.devshell.url = "github:numtide/devshell";

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    flake-utils,
    vscode-server,
    home-manager,
    sops-nix,
    devshell,
    nil,
  } @ inputs: let
    inherit (self) outputs;
    devShells = flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;

        overlays = [
          devshell.overlays.default
        ];
      };
    in {
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
      nixosConfigurations.pi4-nixos = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
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
            services.homebridge.enable = true;
            services.homebridge.openFirewall = true;
          }

          # User environment managed by Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs outputs;
              headless = true;
            };
            home-manager.users.jloos = {
              imports = [
                ./users/jloos/home.nix
              ];
            };
          }

          vscode-server.nixosModule
          (
            {
              config,
              pkgs,
              ...
            }: {
              services.vscode-server.enable = true;
            }
          )

          ./nixos/modules/snowflake
        ];
      };

      homeConfigurations.jloos-macos = let
        system = "aarch64-darwin";
        pkgs = import nixpkgs {
          inherit system;
          overlays = [nil.overlays.default];
        };
      in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs outputs;
            headless = false;
          };

          modules = [
            ./users/jloos/home.nix
          ];
        };

      # https://github.com/NixOS/nixpkgs/blob/1a173c89426ab705aac55872740362bc1a0b6cfd/pkgs/top-level/darwin-packages.nix#LL228C3-L242C9
      builder = let
        system = "aarch64-darwin";
        pkgs = import nixpkgs {inherit system;};
        toGuest = builtins.replaceStrings ["darwin"] ["linux"];

        nixos = import "${nixpkgs}/nixos" {
          configuration = {
            imports = [
              # https://github.com/NixOS/nixpkgs/blob/6d89aa8f1d238cc5ed97215f7e229b8283bef027/nixos/modules/profiles/macos-builder.nix
              "${nixpkgs}/nixos/modules/profiles/macos-builder.nix"
            ];

            virtualisation.host = {inherit pkgs;};
            virtualisation = {
              diskSize = pkgs.lib.mkForce (40 * 1024);
              memorySize = pkgs.lib.mkForce (4 * 1024);
            };
          };

          system = toGuest pkgs.hostPlatform.system;
        };
      in
        nixos.config.system.build.macos-builder-installer;

      nixosConfigurations."nixbuilder.qwiz.buzz" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;

        modules = [
          "${nixpkgs}/nixos/modules/virtualisation/google-compute-image.nix"
          ./machines/nixbuilder/configuration.nix
        ];
      };

      packages.aarch64-linux = {
        default = self.nixosConfigurations.pi4-nixos.config.system.build.sdImage;
      };

      packages.aarch64-darwin = {
        builder = self.builder;
      };

      packages.x86_64-linux = {
        googleComputeImage = self.nixosConfigurations."nixbuilder.qwiz.buzz".config.system.build.googleComputeImage;
      };
    }
    // devShells;
}
