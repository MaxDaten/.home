{
  description = "Raspberry Pi NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixos-hardware.url = github:NixOS/nixos-hardware/master;
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.vscode-server.url = "github:msteen/nixos-vscode-server";
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.sops-nix = {
    url = github:Mic92/sops-nix;
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    flake-utils,
    vscode-server,
    home-manager,
    sops-nix,
  }: let
    system = "aarch64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    devShells = flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          git
          direnv
        ];
      };
    });
  in
    {
      # formatter = nixpkgs.legacyPackages.aarch64-darwin.alejandra;

      # Issue: https://github.com/NixOS/nixos-hardware/issues/360#issuecomment-1009626988
      # Workaround: https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
      # overlays.default = overlay-allowMissing;

      nixosConfigurations.pi4-nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./machines/pi4-nixos
          ./users/jloos
          ./nixos/modules/fixup-allow-missing-modules.nix
          nixos-hardware.nixosModules.raspberry-pi-4
          ./nixos/modules/pi4-sd-image.nix
          ./nixos/modules/system.nix
          ./nixos/modules/my-networks.nix
          # Secret Management
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jloos = {
              imports = [ (./. + "/users/jloos/home.nix") ];
            };
          }
        ];
      };

      packages.aarch64-linux.default = self.nixosConfigurations.pi4-nixos.config.system.build.sdImage;
    }
    // devShells;
}
