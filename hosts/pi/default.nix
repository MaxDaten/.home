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
  host = "pi";
  system = "aarch64-linux";
  inherit (inputs.nixpkgs) lib;
  inherit (inputs.nixpkgs.lib) nixosSystem;
in
{
  perSystem = { config, self', inputs', pkgs, system, ... }: {

    apps."nixos-switch-${host}".program =
      let
        script = pkgs.writeShellApplication {
          name = "nixos-switch-${host}";
          # https://www.haskellforall.com/2023/01/announcing-nixos-rebuild-new-deployment.html
          text = ''
            ${lib.getExe pkgs.nixos-rebuild} switch \
              --flake .#${host} \
              --target-host "${host}" \
              --use-remote-sudo \
              --build-host ${host} \
              --fast
          '';
        };
      in
      lib.getExe script;
  };

  flake = {

    # minimal pi

    nixosConfigurations = {
      "${host}-minimal" = withSystem system ({ pkgs, inputs', ... } @ ctx:
        let
          inherit (inputs.nixos.lib) nixosSystem;
          specialArgs = {
            inherit inputs;
            inherit (self) outputs;
          };

          basic-config = { pkgs, lib, ... }: {
            # bcm2711 for rpi 3, 3+, 4, zero 2 w
            # bcm2712 for rpi 5
            # See the docs at:
            # https://www.raspberrypi.com/documentation/computers/linux_kernel.html#native-build-configuration
            raspberry-pi-nix.board = "bcm2712";

            #  nixos config
            # time.timeZone = "America/New_York";
            # users.users.root.initialPassword = "root";
            # networking = {
            #   hostName = host;
            #   useDHCP = false;
            #   interfaces = {
            #     wlan0.useDHCP = true;
            #     eth0.useDHCP = true;
            #   };
            # };

            hardware = {
              bluetooth.enable = true;
              raspberry-pi.config = {
                all = {
                  base-dt-params = {
                    # enable autoprobing of bluetooth driver
                    # https://github.com/raspberrypi/linux/blob/c8c99191e1419062ac8b668956d19e788865912a/arch/arm/boot/dts/overlays/README#L222-L224
                    krnbt = {
                      enable = true;
                      value = "on";
                    };
                  };
                };
              };
            };
          };

        in
        nixosSystem {
          inherit system;
          inherit pkgs;
          inherit specialArgs;

          modules = [
            inputs.raspberry-pi-nix.nixosModules.raspberry-pi
            basic-config
          ];
        }
      );

      ${host} = nixosSystem {
        inherit system;

        modules = [
          inputs.raspberry-pi-nix.nixosModules.raspberry-pi
          ./modules/pi-config.nix
          ./configuration.nix
          inputs.sops-nix.nixosModules.sops
          {
            sops.defaultSopsFile = ./secrets.yaml;
            sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
            sops.age.keyFile = "/var/lib/sops-nix/key.txt";
            sops.age.generateKey = true;
          }
          inputs.vscode-server.nixosModule
          ./modules/vscode-server.nix

          # ./modules/system-dashboard

          # # # User environment managed by Home Manager
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs // {
              headless = true;
            };
          }
          (import ../../users/jloos)
          # # ./nixos/modules/homebridge
          # # {
          # #   services.homebridge.enable = true;
          # #   services.homebridge.openFirewall = true;
          # # }
        ];
      };
    };

    packages.aarch64-linux."${host}-sd-image" = self.nixosConfigurations.${host}.config.system.build.sdImage;

    apps.aarch64-darwin."flash-${host}-sd-image".program = withSystem "aarch64-darwin" ({ pkgs, ... }: pkgs.writeShellApplication {
      name = "flash-${host}-sd-image";
      runtimeInputs = [ ];
      text = ''
        export img="${self.nixosConfigurations.${host}.config.system.build.sdImage}/sd-image/${self.nixosConfigurations.${host}.config.sdImage.imageName}.zst"
        echo "Flashing SD card: $img"
        read -p "Write image $img? (This may take a while) [yn]: " -r WRITE_IMAGE

        case $WRITE_IMAGE in
          [Yy]* ) 
              echo "✍️ Write image to sd card"
              diskutil list
              
              read -p "Enter device: " -r TARGET_SD
              
              echo "Unmounting disk to allow writing to disk"
              sudo diskutil unmount "$TARGET_SD" || true
              sudo diskutil unmountDisk "$TARGET_SD"

              echo "Start writing to disk"
              TARGET_SD="''${TARGET_SD//disk/rdisk}" # Unbuffered write
              ${lib.getExe pkgs.zstd} -d $img -c | sudo ${lib.getExe' pkgs.coreutils "dd"} of="$TARGET_SD" conv=fsync bs=4M iflag=fullblock status=progress

              echo "Done... ejecting sd"
              sudo diskutil eject "$TARGET_SD"
              ;;
          * ) exit;;
        esac

      '';
    });
  };
}
