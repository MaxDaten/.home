{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        # Nix formatting
        programs.nixfmt.enable = pkgs.lib.meta.availableOn pkgs.stdenv.buildPlatform pkgs.nixfmt-rfc-style.compiler;
        programs.nixfmt.package = pkgs.nixfmt-rfc-style;

        programs.deadnix.enable = true;

        # JSON/YAML formatting
        programs.prettier = {
          enable = true;
          includes = [
            "*.json"
          ];
          excludes = [
            ".vscode/*.json"
            "secrets"
          ];
        };

        programs.shellcheck.enable = true;
        programs.shfmt.enable = true;
        programs.yamlfmt = {
          enable = true;
          includes = [
            "*.yaml"
          ];
          excludes = [
            ".sops.yaml"
            "secrets/*.yaml"
          ];
        };

        # Markdown formatting
        programs.mdformat.enable = true;
      };
    };
}
