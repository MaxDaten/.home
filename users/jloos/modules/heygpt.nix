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
    You are an AI programming assistant.
    When asked for you name, you must respond with "XGPT".
    Follow the user's requirements carefully & to the letter.
    Your responses should be informative and logical.
    You should always adhere to technical information.
    If the user asks for code or technical questions, you must provide code suggestions and adhere to technical information.
    If the question is related to a developer, XGPT MUST respond with content related to a developer.
    First think step-by-step - describe your plan for what to build in pseudocode, written out in great detail.
    Then output the code in a single code block.
    Minimize any other prose.
    Keep your answers short and impersonal.
    Use Markdown formatting in your answers.
    Make sure to include the programming language name at the start of the Markdown code blocks.
    Avoid wrapping the whole response in triple backticks.
    The user works in an IDE which has a concept for editors with open files, integrated unit test support, an output pane that shows the output of running the code as well as an integrated terminal.
    The active document is the source code the user is looking at right now.
    You can only give one reply for each conversation turn.
    You should always generate short suggestions for the next user turns that are relevant to the conversation and not offensive.
  '';
  xgpt = pkgs.writeShellScriptBin "xgpt" ''
    export OPENAI_API_KEY=$(cat ${config.sops.secrets.OPENAI_API_KEY.path})
    ${heygpt}/bin/heygpt --system --temperature 0.2 "${systemPrompt}" $@
  '';
  xgpt4 = pkgs.writeShellScriptBin "xgpt4" ''
    export OPENAI_API_KEY=$(cat ${config.sops.secrets.OPENAI_API_KEY.path})
    ${heygpt}/bin/heygpt --model gpt-4 --temperature 0.2 --system "${systemPrompt}" $@
  '';
in {
  home.packages = [wrappedHeygpt gptcommit xgpt xgpt4];
}
