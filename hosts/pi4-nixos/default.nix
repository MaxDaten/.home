{ self, withSystem, inputs, lib, options, flake-parts-lib, specialArgs, ...
} @ top-level: 
let
  system = "aarch64-linux";
  inherit (inputs.nixpkgs) lib;
in {
  flake = {

    nixosConfigurations.pi4-nixos = 
      withSystem system ({ pkgs, inputs', ... } @ ctx: 
        let
          specialArgs = {
            inherit inputs;
            inherit (self) outputs;
          };
        in
        lib.nixosSystem {
          inherit system;
          inherit pkgs;
          inherit specialArgs;

          modules = [
            inputs.nixos-hardware.nixosModules.raspberry-pi-4
            ./configuration.nix
            ./sd-image.nix
            inputs.sops-nix.nixosModules.sops {
              sops.defaultSopsFile = ./secrets.yaml;
              sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
              sops.age.keyFile = "/var/lib/sops-nix/key.txt";
              sops.age.generateKey = true;
            }
            inputs.vscode-server.nixosModule {
              services.vscode-server.enable = true;
              services.vscode-server.nodejsPackage = pkgs.nodejs_20;
            }
            # ./nixos/modules/build-machines.nix

            # ./nixos/modules/system-dashboard
            # # ./nixos/modules/homebridge
            # # {
            # #   services.homebridge.enable = true;
            # #   services.homebridge.openFirewall = true;
            # # }

            # # User environment managed by Home Manager
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs // {
                headless = true;
              };
            }
            (import ../../users/jloos)
          ];
        }
      );
    
    packages.aarch64-linux.pi4-nixos-sd-image = self.nixosConfigurations.pi4-nixos.config.system.build.sdImage;

    apps.aarch64-darwin.flash-pi4-nixos-sd-image.program = withSystem "aarch64-darwin" ({pkgs, ...}: pkgs.writeShellScriptBin "flash-sd-card" ''
      echo "Flashing SD card: ${self.nixosConfigurations.pi4-nixos.config.system.build.sdImage}"
    '');
  };
}