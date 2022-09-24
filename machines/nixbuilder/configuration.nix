{...}: {
  imports = [
    <nixpkgs/nixos/modules/virtualisation/google-compute-image.nix>
  ];
  virtualisation.libvirtd.enable = true;
  security.polkit.enable = true;
  security.sudo.wheelNeedsPassword = false;
  users.extraUsers.jloos = {
    isNormalUser = true;
    createHome = true;
    home = "/home/jloos";
    description = "jloos";
    group = "users";
    extraGroups = ["wheel" "libvirtd"];
    useDefaultShell = true;
    hashedPassword = "$6$H9kP.kHWqSBn1rE4$huEYYhX0UrpsCCViIwWFHinRJnMVjgSbOoynKF0t79Itlb5ReqAztQDm.Q.t5LXl/70vuVnCx8bXf3nLJHd1S0";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC788mvgo7yQdz3LiH0fhyoGOW1sqJ8lnk7Kf5tD6Y8b jloos@pi4-nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElfsEDFF7jnwSFGXsxbhvsHpBOMsjOAcQseFAtdbB0Z jloos@macos"
    ];
  };
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];
}
