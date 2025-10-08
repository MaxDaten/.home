{ pkgs, config, ... }:

{
  imports = [ ./nix/modules/devenv/treefmt.nix ];

  name = ".home shell";

  packages = with pkgs; [
    sops
    age
    ssh-to-age

    just

  ];

  env.SOPS_AGE_KEY_FILE = "/Users/jloos/.config/sops/age/keys.txt";
  env.SOPS_AGE_KEY_DIRECTORY = "/Users/jloos/.config/sops/age";

  # Claude Code MCP server configuration
  claude.code = {
    enable = true;

    mcpServers = {
      # Local devenv MCP server
      devenv = {
        type = "stdio";
        command = "${pkgs.devenv}/bin/devenv";
        args = [ "mcp" ];
        env = {
          DEVENV_ROOT = config.devenv.root;
        };
      };
    };
  };
}
