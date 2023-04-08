{pkgs, ...}: {
  programs.fzf = let
    fd = "${pkgs.fd}/bin/fd";
  in {
    enable = true;
    changeDirWidgetCommand = "${fd} --type d --hidden --follow --exclude .git --no-ignore";
    changeDirWidgetOptions = ["--preview 'tree -C {} | head -200'"];
  };
}
