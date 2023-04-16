{
  lib,
  pkgs,
  isDarwin,
  config,
  ...
}: let
  heygpt = pkgs.rustPlatform.buildRustPackage {
    name = "heygpt";
    src = pkgs.fetchFromGitHub {
      owner = "fuyufjh";
      repo = "heygpt";
      rev = "b84947025821ce4b3d7f96b8c0c2409b2d6743f9";
      hash = "sha256-+Kx8OmUbqL9FRD8uA2W2iSmsKxHzHYTZVgCKEO0gC30=";
    };
    cargoHash = "sha256-ag3QfjCZgw9qR8gjZ3KyhY+X5IEmbZD3U/ai20zVtzE=";

    buildInputs = [pkgs.openssl] ++ lib.optionals isDarwin [pkgs.darwin.apple_sdk.frameworks.Security];
    nativeBuildInputs = [pkgs.pkg-config];

    meta = with lib; {
      description = "A simple command line tool to interact with GPT";
      homepage = "https://github.com/fuyufjh/heygpt";
      license = licenses.mit;
    };
  };

  wrappedHeygpt = pkgs.writeShellScriptBin "heygpt" ''
    export OPENAI_API_KEY=$(cat ${config.sops.secrets.OPENAI_API_KEY.path})
    ${heygpt}/bin/heygpt $@
  '';

  gptcommit = pkgs.writeShellScriptBin "gptcommit" ''
    export OPENAI_API_KEY=$(cat ${config.sops.secrets.OPENAI_API_KEY.path})
    ${pkgs.gptcommit}/bin/gptcommit $@
  '';
in {
  home.packages = [wrappedHeygpt gptcommit];
}
