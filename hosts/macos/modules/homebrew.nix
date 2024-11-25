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

  homebrew = {
    enable = true;

    user = "jloos";

    onActivation.cleanup = "zap";

    taps = builtins.attrNames config.nix-homebrew.taps;

    casks = [
      "keyclu"
    ];

    masApps = {
      "Discovery" = 1381004916;
      "WhatsApp" = 310633997;
      "WireGuard" = 1451685025;
      "Strongbox - Password Manager" = 897283731;
      "AusweisApp" = 948660805;
    };
  };
}
