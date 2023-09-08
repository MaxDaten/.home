# Following: https://github.com/SamirHafez/config/blob/ef14103d4fb31d9e95264b05c78b57a1201b3c65/pi/modules/homebridge.nix
{ config
, pkgs
, lib
, ...
}: {
  imports = [
    ./homebridge.nix
    ./reverse-proxy.nix
  ];
}
