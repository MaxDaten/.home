{ pkgs, ... }: {
  programs.fzf =
    let
      fd = "${pkgs.fd}/bin/fd";
    in
    {
      enable = true;
      enableFishIntegration = true;
      # Alt-C
      changeDirWidgetCommand = "${fd} --type d --hidden --follow --exclude .git --no-ignore";
      changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
    };

  programs.fsih.interactiveShellInit = ''
    set --global --export FZF_CTRL_T_OPTS "--walker-skip .git,node_modules,target --preview 'bat --style=number,header,grid --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
  '';
}
