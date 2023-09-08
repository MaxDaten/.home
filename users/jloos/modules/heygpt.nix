{ lib
, pkgs
, isDarwin
, config
, ...
}:
let
  heygpt = pkgs.rustPlatform.buildRustPackage {
    name = "heygpt";
    src = pkgs.fetchFromGitHub {
      owner = "fuyufjh";
      repo = "heygpt";
      rev = "cbe92edd665d0559b3f4091aed214400c11bdf01";
      hash = "sha256-Gtbb0G7tV+cjbq/74dnZKIwWZgNfSJl0My6F4OmAdhU=";
    };
    cargoHash = "sha256-E1K8N7CEO/1gYrhkQ5awaynldWBunnnaBmAZzvnaXx4=";

    buildInputs = [ pkgs.openssl ] ++ lib.optionals isDarwin [ pkgs.darwin.apple_sdk.frameworks.Security ];
    nativeBuildInputs = [ pkgs.pkg-config ];

    meta = with lib; {
      description = "A simple command line tool to interact with GPT";
      homepage = "https://github.com/fuyufjh/heygpt";
      license = licenses.mit;
    };
  };

  wrappedHeygpt = pkgs.writeShellScriptBin "heygpt" ''
    export OPENAI_API_KEY=$(cat ${config.sops.secrets.OPENAI_API_KEY.path})
    export OPENAI_API_BASE="https://api.openai.com/v1"
    ${heygpt}/bin/heygpt $@
  '';

  gptcommit = pkgs.writeShellScriptBin "gptcommit" ''
    export OPENAI_API_KEY=$(cat ${config.sops.secrets.OPENAI_API_KEY.path})
    export OPENAI_API_BASE="https://api.openai.com/v1"
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
    export OPENAI_API_BASE="https://api.openai.com/v1"
    ${heygpt}/bin/heygpt --system --temperature 0.2 "${systemPrompt}" $@
  '';
  xgpt4 = pkgs.writeShellScriptBin "xgpt4" ''
    export OPENAI_API_KEY=$(cat ${config.sops.secrets.OPENAI_API_KEY.path})
    export OPENAI_API_BASE="https://api.openai.com/v1"
    ${heygpt}/bin/heygpt --model gpt-4 --temperature 0.2 --system "${systemPrompt}" $@
  '';

  proofReadingSystemPrompt = ''
        Given some text, make it clearer.

    Do not rewrite it entirely. Just make it clearer and more readable.

    Take care to emulate the original text's tone, style, and meaning.

    Approach it like an editor — not a rewriter.

    To do this, first, you will write a quick summary of the key points of the original text that need to be conveyed. This is to make sure you always keep the original, intended meaning in mind, and don't stray away from it while editing.

    Then, you will write a new draft. Next, you will evaluate the draft, and reflect on how it can be improved.

    Then, write another draft, and do the same reflection process.

    Then, do this one more time.

    After writing the three drafts, with all of the revisions so far in mind, write your final, best draft.

    Do so in this format:
    ===
    # Meaning
    $meaning_bulleted_summary

    # Round 1
        ## Draft
            ``$draft_1``
        ## Reflection
            ``$reflection_1``

    # Round 2
        ## Draft
            ``$draft_2``
        ## Reflection
            ``$reflection_2``

    # Round 3
        ## Draft
            ``$draft_3``
        ## Reflection
            ``$reflection_3``

    # Final Draft
        ``$final_draft``
    ===

    To improve your text, you'll need to go through three rounds of writing and reflection. For each round, write a draft, evaluate it, and then reflect on how it could be improved. Once you've done this three times, you'll have your final, best draft.
  '';
  proofgpt = pkgs.writeShellScriptBin "proofgpt" ''
    if [ -z "$1" ]; then
      echo "Usage: proofgpt <markdown file>"
      exit 1
    fi
    export OPENAI_API_KEY=$(cat ${config.sops.secrets.OPENAI_API_KEY.path})
    export OPENAI_API_BASE="https://api.openai.com/v1"
    ${heygpt}/bin/heygpt --model gpt-4 --temperature 0.5 --system "${proofReadingSystemPrompt}" $(cat $1) | ${pkgs.glow}/bin/glow -
  '';
in
{
  home.packages = [ wrappedHeygpt gptcommit xgpt xgpt4 proofgpt ];
}
