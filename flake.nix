{
  description = "Personal NixOS configuration";

  inputs =
    {
      devenv-root = {
        url = "file+file:///dev/null";
        flake = false;
      };

      # Nix Derivations
      nixpkgs.url = "nixpkgs/nixpkgs-unstable";
      nixos-darwin.url = "nixpkgs/nixpkgs-unstable";


      darwin = {
        url = "github:lnl7/nix-darwin";
        inputs.nixpkgs.follows = "nixos-darwin";
      };

      flake-parts.url = "github:hercules-ci/flake-parts";

      # System Tools
      nixos-hardware = {
        url = "github:NixOS/nixos-hardware/master";
      };
      home-manager = {
        url = "github:nix-community/home-manager/master";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      sops-nix = {
        url = "github:Mic92/sops-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      # Development environment
      devenv.url = "github:cachix/devenv";
      nix2container = {
        url = "github:nlewo/nix2container";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      vscode-server.url = "github:msteen/nixos-vscode-server";
      nil.url = "github:oxalica/nil";
    };

  outputs =
    { self
    , nixpkgs
    , nixos-darwin
    , darwin
    , flake-parts
    , home-manager
    , sops-nix
    , devenv
    , nil
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
    in
    flake-parts.lib.mkFlake { inherit inputs; } (top-level@{ self, withSystem, lib, ... }: {
      imports = [
        inputs.devenv.flakeModule
        ./hosts/pi4-nixos/default.nix
      ];

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        devenv.shells.default = {
          devenv.root =
            let
              devenvRootFileContent = builtins.readFile inputs.devenv-root.outPath;
            in
            pkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;

          name = ".home shell";

          imports = [ ];

          packages = with pkgs; [
            sops
            age
            ssh-to-age
            age

            stress
            speedtest-cli

            node2nix
            rsync
            nil.packages.${system}.default
            nixpkgs-fmt
          ];

          env.SOPS_AGE_KEY_FILE = "/Users/jloos/.config/sops/age/keys.txt";
          env.SOPS_AGE_KEY_DIRECTORY = "/Users/jloos/.config/sops/age";
        };
      };

      flake = {
        #   # scutil --get LocalHostName
        darwinConfigurations = {
          "MacBook-Pro" = darwin.lib.darwinSystem {
            system = "aarch64-darwin";

            specialArgs = {
              inherit inputs outputs;
            };

            modules = [
              ./hosts/macos/configuration.nix
              ./hosts/macos/modules/linux-builder.nix
              ./nixos/modules/build-machines.nix

              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = {
                  inherit inputs outputs;
                  headless = false;
                };
                home-manager.users.jloos = import ./users/jloos/home.nix;
              }
            ];
          };
        };

        homeManagerModules = { };
      };
    });
}
