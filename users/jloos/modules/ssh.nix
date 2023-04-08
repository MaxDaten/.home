{...}: {
  programs.ssh.enable = true;
  programs.ssh.matchBlocks = {
    "pi4-nixos" = {
      hostname = "pi4-nixos";
      user = "jloos";
      identitiesOnly = true;
      identityFile = [
        "~/.ssh/id_ed25519"
        "~/.ssh/id_rsa"
      ];
    };

    "maandr" = {
      hostname = "maandr.de";
      user = "root";
    };
  };
}
