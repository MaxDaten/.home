{ config
, pkgs
, ...
}:
let
  mount = "/mnt/timecapsule";
in
{

  fileSystems.mount = {
    device = "/dev/disk/by-label/TIMECAPSULE";
    fsType = "ext4";
  };

  services.samba = {
    enable = true;
    shares = {
      tm_share = {
        path = mount;
        "valid users" = "jloos";
        public = "no";
        writeable = "yes";
        "force user" = "jloos";
        "fruit:aapl" = "yes";
        "fruit:time machine" = "yes";
        "vfs objects" = "catia fruit streams_xattr";
      };
    };
  };
}
