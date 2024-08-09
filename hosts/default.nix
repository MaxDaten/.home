{ inputs
, outputs
, self
, withSystem
, ...
}:
let
  inherit (inputs.nixpkgs) lib;
  inherit (lib) nixosSystem;
  inherit (inputs.darwin.lib) darwinSystem;
  specialArgs = { inherit inputs outputs; };
in
{
  flake.darwinConfigurations =
    {
      # scutil --get LocalHostName
      "MacBook-Pro" = darwinSystem {
        system = "aarch64-darwin";
        inherit specialArgs;

        modules = [
          ./macos
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs // {
              headless = false;
            };
            home-manager.users.jloos = import ../users/jloos/home.nix;
          }
        ];
      };
    };

  flake.nixosConfigurations =
    let
      system = "aarch64-linux";
    in
    {
      # minimal pi for bootstrapping and quick testing
      pi-minimal = nixosSystem {
        inherit system specialArgs;

        modules = [
          inputs.raspberry-pi-nix.nixosModules.raspberry-pi
          ./pi/pi-config.nix
        ];
      };

      # full pi configuration
      pi = nixosSystem {
        inherit system specialArgs;

        modules = [
          inputs.raspberry-pi-nix.nixosModules.raspberry-pi
          ./pi
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
      };
    };

  flake.packages = {
    aarch64-linux."pi-sd-image" = self.nixosConfigurations.pi.config.system.build.sdImage;
    aarch64-linux."pi-minimal-sd-image" = self.nixosConfigurations.pi-minimal.config.system.build.sdImage;
  };

  flake.apps = {
    aarch64-darwin."flash-pi-sd-image".program = withSystem "aarch64-darwin" ({ pkgs, ... }: pkgs.writeShellApplication {
      name = "flash-pi-sd-image";
      runtimeInputs = [ ];
      text = ''
        export img="${self.nixosConfigurations.pi.config.system.build.sdImage}/sd-image/${self.nixosConfigurations.pi.config.sdImage.imageName}.zst"
        echo "Flashing SD card: $img"
        read -p "Write image $img? (This may take a while) [yn]: " -r WRITE_IMAGE

        case $WRITE_IMAGE in
          [Yy]* ) 
              echo "Write image to sd card"
              diskutil list

              read -p "Enter device: " -r TARGET_SD

              echo "Unmounting disk to allow writing to disk"
              sudo diskutil unmount "$TARGET_SD" || true
              sudo diskutil unmountDisk "$TARGET_SD"

              echo "Start writing to disk"
              TARGET_SD="''${TARGET_SD//disk/rdisk}" # Unbuffered write
              ${lib.getExe pkgs.zstd} -d $img -c | sudo ${lib.getExe' pkgs.coreutils "dd"} of="$TARGET_SD" conv=fsync bs=4M iflag=fullblock status=progress

              echo "✓ Done... ejecting sd"
              sudo diskutil eject "$TARGET_SD"
              ;;
          * ) exit;;
        esac
      '';
    });
  };

  perSystem = { pkgs, ... }: {
    apps."nixos-switch-pi".program =
      let
        script = pkgs.writeShellApplication {
          name = "nixos-switch-pi";
          # https://www.haskellforall.com/2023/01/announcing-nixos-rebuild-new-deployment.html
          text = ''
            ${lib.getExe pkgs.nixos-rebuild} switch \
              --flake .#pi \
              --target-host "pi" \
              --use-remote-sudo \
              --build-host pi \
              --fast
          '';
        };
      in
      lib.getExe script;
  };

  imports = [ ];
}
