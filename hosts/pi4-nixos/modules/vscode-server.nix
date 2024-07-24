{ inputs
, config
, pkgs
, lib
, ...
}: inputs.vscode-server.nixosModule {
        services.vscode-server.enable = true;
        services.vscode-server.nodejsPackage = pkgs.nodejs_20;
      }