{ ... }: {
  programs.broot.enable = true;
  programs.bat.enable = true;
  programs.bash.enable = true;
  programs.bash.enableCompletion = true;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.config = { global = { log_filter = "^$"; }; };
}
