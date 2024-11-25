{ config, inputs, ... }: {
  nix-homebrew = {
    enable = true;
    enableRosetta = true;

    user = "jloos";
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
    };

    mutableTaps = false;
  };
}
