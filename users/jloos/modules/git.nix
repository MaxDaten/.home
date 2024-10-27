{ pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = "Jan-Philip Loos";
    userEmail = "maxdaten@gmail.com";

    aliases = {
      r = "rebase --autostash";
      # https://softwaredoug.com/blog/2022/11/09/idiot-proof-git-aliases.html
      mainbranch = "!git remote show origin | sed -n '/HEAD branch/s/.*: //p'";
      switch-default = "!git switch $(git mainbranch)";
      sd = "switch-default";
      sync = "!git pull origin $(git mainbranch) --rebase";
      update = "!git pull origin $(git rev-parse --abbrev-ref HEAD) --rebase";
      squash = "!git rebase -v -i $(git mainbranch)";
      publish = "push origin HEAD --force-with-lease";
      pub = "publish";
      amend = "commit --amend --no-edit";
    };

    extraConfig = {
      core = {
        autocrlf = "input";
        excludesfile = (pkgs.writeText ".gitignore"
          (builtins.readFile ./global.gitignore)).outPath;
      };

      pull = { rebase = false; };

      push = { autoSetupRemote = true; };

      init = { defaultBranch = "main"; };
    };
  };
}
