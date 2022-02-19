{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jloos";
  home.homeDirectory = "/Users/jloos";

  home.packages = with pkgs; [
    htop
    fortune
    ripgrep
    jq
    tree
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Configurations

  programs.bat.enable = true;

  # Git
  programs.git = {
    enable = true;
    userName = "Jan-Philip Loos";
    userEmail = "maxdaten@gmail.com";

    aliases = {
      r = "rebase --autostash";
    };

    extraConfig = {
      core = {
        autocrlf = "input";
        # excludesfile = /Users/jloos/.gitignore;
      };

      pull = {
        rebase = false;
      };

      init = {
        defaultBranch = "main";
      };
    };
  };

  # Vim
  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = ''
      colorscheme gruvbox
    '';

    plugins = with pkgs.vimPlugins; [
      gruvbox

      # Languages
      vim-nix
      
      vim-fish
      
      vim-go
      
      vim-pandoc
      vim-pandoc-syntax
    ];

  };

}
