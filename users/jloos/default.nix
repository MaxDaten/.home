# System settings of user
{ config
, pkgs
, ...
}: {
  programs.fish.enable = true;
  users.users.jloos = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "lp"
      "libvirtd"
      "qemu-libvirtd"
      "timemachine"
      config.users.groups.keys.name # Allow access to secrets
    ];
    shell = pkgs.fish;

    # Password hash generated via: mkpasswd -m sha-512 <password>
    # hashedPasswordFile = "$6$3nKcfq7rxyB0GCZg$oghIkUllrueYjxJSoS3LkMoGAdQmznb8xVo4Jr6m1upN0GvVPMhr1tHxoQrzWv1w55.rD43eou6OJT0tULi5o/";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElfsEDFF7jnwSFGXsxbhvsHpBOMsjOAcQseFAtdbB0Z jloos@macos"
      # Generated via: ssh-keygen -t ed25519-sk -O resident -O application=ssh:macbook-pro -O verify-required
      # https://developers.yubico.com/SSH/Securing_SSH_with_FIDO2.html
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAII/TQ6VaYALM58rbQCHOwFt52Kzrt1CzmQJF0566/VALAAAAD3NzaDptYWNib29rLXBybw== jloos@macos"
    ];
  };

  # User environment managed by Home Manager
  home-manager.users.jloos = {
    programs.fish.enable = true;
    imports = [
      ./home.nix
    ];
  };
}
