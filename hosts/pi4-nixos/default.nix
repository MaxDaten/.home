{ self
, withSystem
, inputs
, lib
, options
, flake-parts-lib
, specialArgs
, ...
} @ top-level:
let
  system = "aarch64-linux";
  inherit (inputs.nixpkgs) lib;
in
{
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
            inputs.disko.nixosModules.disko
            ./configuration.nix
            ./sd-image.nix
            inputs.sops-nix.nixosModules.sops
            {
              sops.defaultSopsFile = ./secrets.yaml;
              sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
              sops.age.keyFile = "/var/lib/sops-nix/key.txt";
              sops.age.generateKey = true;
            }
            inputs.vscode-server.nixosModule

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

    apps.aarch64-darwin.flash-pi4-nixos-sd-image.program = withSystem "aarch64-darwin" ({pkgs, ...}: pkgs.writeShellApplication {
      name = "flash-pi4-nixos-sd-image";
      runtimeInputs = [ ];
      text = ''
        IMAGE_FILE="${self.nixosConfigurations.pi4-nixos.config.system.build.sdImage}/sd-image/${self.nixosConfigurations.pi4-nixos.config.sdImage.imageName}"
        echo "Flashing SD card: $IMAGE_FILE"
        read -p "Write image $IMAGE_FILE? (This may take a while) [yn]: " -r WRITE_IMAGE

        case $WRITE_IMAGE in
          [Yy]* ) 
              echo "✍️ Write image to sd card"
              diskutil list
              
              read -p "Enter device: " -r TARGET_SD
              
              echo "Unmounting disk to allow writing to disk"
              sudo diskutil unmount "$TARGET_SD" || true
              sudo diskutil unmountDisk "$TARGET_SD"

              echo "Start writing to disk"
              sudo dd if="$IMAGE_FILE" of="$TARGET_SD" bs=8M conv=fsync status=progress

              echo "Done... ejecting sd"
              sudo diskutil eject "$TARGET_SD"
              ;;
          * ) exit;;
        esac

      '';
    });
  };
}