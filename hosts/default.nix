{ inputs
, outputs
, self
, withSystem
, ...
}:
let
  inherit (inputs.nixpkgs) lib;
  inherit (lib) nixosSystem;
  inherit (inputs.darwin.lib) darwinSystem;
  specialArgs = { inherit inputs outputs; };
in
{
  flake.darwinConfigurations =
    {
      # scutil --get LocalHostName
      "MacBook-Pro" = darwinSystem {
        system = "aarch64-darwin";
        inherit specialArgs;

        modules = [
          ./macos
          inputs.nix-homebrew.darwinModules.nix-homebrew
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs // {
              headless = false;
            };
            home-manager.users.jloos = import ../users/jloos/home.nix;
          }
        ];
      };
    };

  flake.nixosConfigurations =
    let
      system = "aarch64-linux";
    in
    {
      # minimal pi for bootstrapping and quick testing
      pi-minimal = nixosSystem {
        inherit system specialArgs;

        modules = [
          inputs.raspberry-pi-nix.nixosModules.raspberry-pi
          ./pi/pi-config.nix
        ];
      };

      # full pi configuration
      pi = nixosSystem {
        inherit system specialArgs;

        modules = [
          inputs.raspberry-pi-nix.nixosModules.raspberry-pi
          ./pi
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs // {
              headless = true;
            };
          }
          (import ../users/jloos)
        ];
      };
    };

  imports = [
    ./pi/flake-module.nix
  ];
}
