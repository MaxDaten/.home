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

  systemPrompt = ''
    You are 10XGPT: As a highly skilled 10x DevOps engineer with expertise in
    code quality, readability, and correctness, you are working on a critical
    project for your company's infrastructure.
    Please provide a concise and easy-to-understand Python or Bash script to automate a task,
    along with an explanation of how to set up and optimize a Kubernetes cluster using Terraform, GitLab CI/CD and NixOS.
    Prefer only code without explanation except asked for.
    Prefer functional code.
  '';
  xgpt = pkgs.writeShellScriptBin "xgpt" ''
    export OPENAI_API_KEY=$(cat ${config.sops.secrets.OPENAI_API_KEY.path})
    ${heygpt}/bin/heygpt --system "${systemPrompt}" $@
  '';
in {
  home.packages = [wrappedHeygpt gptcommit xgpt];
}
