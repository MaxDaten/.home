{ pkgs, lib, ... }: {

  boot.growPartition = true;
  boot.loader = {
    timeout = 3;
    efi.canTouchEfiVariables = false;
    grub = {
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
      configurationLimit = 5;
    };
  };

  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];

  environment.systemPackages = with pkgs; [
    # system tools
    libraspberrypi

    # minimal tools
    vim
    gitMinimal
    bash
  ];

  # Select internationalisation properties.
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.enable = true;
  # User & Additional
  users.extraUsers.root.openssh.authorizedKeys.keys = [
    # "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDICvbuJuq1NNPE0bPVA8s2HGh4FBGMW7mbl5iLzyDfCdvuG0LWs56OtqrnRK/d18cik3r7DIFQ2/B7d6kz2uCcUmV8BegQQ1atud532gIRMUI9s/v4zcUnmCtoUDBbWUiEJvbjNU8oJT8VxWmKnD8nSFuCpSttER7IBdB0oICEPTPvTq01pafrhD8L/L+pS4mKFHjARBuNhi7Va7TEbbIuQQgt028fMjgaL9b/dS1lHUn5Uw9yd3/MfLUS7fNhlK+cn6HvJfQL7FgH5WXZBfxiVJo1iPmFTSio6Qo7PyY27Po8zEmNA+7mNHBms4rloOGYDHmoHY1tSuc1cVfMfL/l jloos@macbook"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPxyE0ilAv126v5gVToRTiH8dha0wquEvI3ZMZpPNvK root@macos"
    # Generated via: ssh-keygen -t ed25519-sk -O resident -O application=ssh:macbook-pro -O verify-required
    # https://developers.yubico.com/SSH/Securing_SSH_with_FIDO2.html
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAII/TQ6VaYALM58rbQCHOwFt52Kzrt1CzmQJF0566/VALAAAAD3NzaDptYWNib29rLXBybw== jloos@macos"
  ];

  security.sudo.wheelNeedsPassword = false;

  # Allow access to secrets
  # systemd.services.some-service = {
  #   serviceConfig.SupplementaryGroups = [config.users.groups.keys.name];
  # };

  # system.copySystemConfiguration = true;

  # Printing
  services.printing.enable = true;
  services.printing.browsing = true;
  services.printing.listenAddresses = [ "*:631" ];
  services.printing.allowFrom = [ "all" ];
  services.printing.defaultShared = true;
  services.printing.extraConf = ''
    DefaultEncryption Never
  '';
  services.printing.drivers = [
    pkgs.brlaser
  ];
}
