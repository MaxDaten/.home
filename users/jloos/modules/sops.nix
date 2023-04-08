{config, ...}: {
  sops = {
    defaultSopsFile = ../../../secrets/main.yaml;
    age.sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    age.generateKey = true;

    # FIXME: Currently not working
    secrets.OPENAI_API_KEY = {
      path = "${config.home.homeDirectory}/.config/openai/OPENAI_API_KEY";
    };
  };
}
