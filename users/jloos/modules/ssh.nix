{ pkgs, ... }: {
  programs.ssh.enable = true;
  programs.ssh.package = pkgs.openssh;
  programs.ssh.matchBlocks = {
    "pi4-nixos" = {
      hostname = "pi4-nixos";
      user = "jloos";
      identitiesOnly = true;
      identityFile = [
        "~/.ssh/id_ed25519_sk"
        # "~/.ssh/id_ed25519"
        # "~/.ssh/id_rsa"
      ];
    };

    "maandr" = {
      hostname = "maandr.de";
      user = "root";
    };

    "linux-builder" = {
      hostname = "localhost";
      user = "builder";
      port = 31022;
      extraOptions = {
        HostKeyAlias = "linux-builder";
      };
    };

    "hydra.m.briends.cloud" = {
      hostname = "hydra.m.briends.cloud";
      user = "jloos";
    };
  };
}
