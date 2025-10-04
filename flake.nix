{
  description = "Personal NixOS configuration";

  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0";

    # Nix Derivations
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";

    darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Install Homebrew
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    # Raspberry Pi
    raspberry-pi-nix = {
      url = "github:nix-community/raspberry-pi-nix/v0.4.0";
    };

    # System Tools
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nnf = {
      url = "github:maxdaten/nixos-nftables-firewall";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Development environment
    devenv.url = "github:cachix/devenv/ce82fad570fd74ac5dfe3ce587ee8b37e918d71f";
    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:msteen/nixos-vscode-server";
    nil.url = "github:oxalica/nil";

    # Code formatting
    treefmt-nix.url = "github:numtide/treefmt-nix";

    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
  };

  nixConfig = {
    extra-trusted-public-keys = [
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "maxdaten-io.cachix.org-1:ZDDi/8gGLSeUEU9JST6uXDcQfNp2VZzccmjUljPHHS8="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    extra-substituters = [
      "https://devenv.cachix.org"
      "https://maxdaten-io.cachix.org"
      "https://nix-community.cachix.org"
    ];
  };

  outputs =
    {
      nixpkgs,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports = [
          inputs.devenv.flakeModule
          ./hosts
          ./nix/modules/treefmt.nix
        ];

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
          "x86_64-darwin"
        ];

        perSystem =
          {
            pkgs,
            system,
            config,
            ...
          }:
          {
            debug = true;

            _module.args.pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };

            devenv.shells.default = {
              devenv.root =
                let
                  devenvRootFileContent = builtins.readFile inputs.devenv-root.outPath;
                in
                pkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;

              name = ".home shell";

              imports = [ ];

              git-hooks.hooks.treefmt = {
                enable = true;
                # configured in nix/modules/treefmt.nix
                package = config.treefmt.build.wrapper;
              };

              packages = with pkgs; [
                sops
                age
                ssh-to-age

                just
                claude-code
                nodejs # required to execute mcp via mcp-remote

                stress
                speedtest-cli

                node2nix
                rsync
                nixd
                zstd
              ];

              env.SOPS_AGE_KEY_FILE = "/Users/jloos/.config/sops/age/keys.txt";
              env.SOPS_AGE_KEY_DIRECTORY = "/Users/jloos/.config/sops/age";
            };
          };
      }
    );
}
