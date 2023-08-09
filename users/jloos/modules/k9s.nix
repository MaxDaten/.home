{pkgs, ...}: {
  programs.k9s = {
    enable = true;

    # Not supported?
    plugins = {
      # https://github.com/derailed/k9s/issues/364
      pinologs = {
        shortCut = "Shift-L";
        confirm = false;
        description = "Logs (pino)";
        scopes = ["po"];
        command = "${pkgs.sh}/bin/sh";
        background = false;
        args = [
          "-c"
          "kubectl logs $NAME -n $NAMESPACE --context $CONTEXT | pino-pretty -c | less -R"
        ];
      };
    };
  };
}
