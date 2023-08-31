# System settings of user
{
  config,
  pkgs,
  ...
}: {
  programs.fish.enable = true;
  users.extraUsers.jloos = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "lp"
      "libvirtd"
      "qemu-libvirtd"
      config.users.groups.keys.name # Allow access to secrets
    ];
    shell = pkgs.fish;

    hashedPassword = "$6$H9kP.kHWqSBn1rE4$huEYYhX0UrpsCCViIwWFHinRJnMVjgSbOoynKF0t79Itlb5ReqAztQDm.Q.t5LXl/70vuVnCx8bXf3nLJHd1S0";
    openssh.authorizedKeys.keys = [
      # "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDICvbuJuq1NNPE0bPVA8s2HGh4FBGMW7mbl5iLzyDfCdvuG0LWs56OtqrnRK/d18cik3r7DIFQ2/B7d6kz2uCcUmV8BegQQ1atud532gIRMUI9s/v4zcUnmCtoUDBbWUiEJvbjNU8oJT8VxWmKnD8nSFuCpSttER7IBdB0oICEPTPvTq01pafrhD8L/L+pS4mKFHjARBuNhi7Va7TEbbIuQQgt028fMjgaL9b/dS1lHUn5Uw9yd3/MfLUS7fNhlK+cn6HvJfQL7FgH5WXZBfxiVJo1iPmFTSio6Qo7PyY27Po8zEmNA+7mNHBms4rloOGYDHmoHY1tSuc1cVfMfL/l jloos@macbook"
      # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElfsEDFF7jnwSFGXsxbhvsHpBOMsjOAcQseFAtdbB0Z jloos@macos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC788mvgo7yQdz3LiH0fhyoGOW1sqJ8lnk7Kf5tD6Y8b jloos@pi4-nixos"
      # Generated via: ssh-keygen -t ed25519-sk -O resident -O application=ssh:macbook-pro -O verify-required
      # https://developers.yubico.com/SSH/Securing_SSH_with_FIDO2.html
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAII/TQ6VaYALM58rbQCHOwFt52Kzrt1CzmQJF0566/VALAAAAD3NzaDptYWNib29rLXBybw== jloos@macos"
    ];
  };

  # User environment managed by Home Manager
  home-manager.users.jloos = {
    home.stateVersion = "23.05";
    programs.fish.enable = true;
    imports = [
      ./home.nix
    ];
  };
}
