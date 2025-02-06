_: {
  imports = [
    ./configuration.nix
    ./modules/linux-builder.nix
    ./modules/homebrew.nix
    ../../darwin/modules/services/ollama.nix
    ../../nixos/modules/build-machines.nix
  ];
}
