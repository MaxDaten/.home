{ pkgs, lib, ... }: {
  # bcm2711 for rpi 3, 3+, 4, zero 2 w
  # bcm2712 for rpi 5
  # See the docs at:
  # https://www.raspberrypi.com/documentation/computers/linux_kernel.html#native-build-configuration
  raspberry-pi-nix.board = "bcm2712";
  raspberry-pi-nix.libcamera-overlay.enable = false;

  hardware = {
    bluetooth.enable = true;
    raspberry-pi.config = {
      all = {
        options = {
          camera_auto_detect.enable = false;

          arm_boost.enable = true;
          arm_boost.value = true;

          otg_mode.enable = true;
          otg_mode.value = true;
        };
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
}
