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

  programs.fish = {
    enable = true;

    plugins = [{
      name="foreign-env";
      src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-foreign-env";
          rev = "dddd9213272a0ab848d474d0cbde12ad034e65bc";
          sha256 = "00xqlyl3lffc5l0viin1nyp819wf81fncqyz87jx8ljjdhilmgbs";
      };
    }];

    shellInit =
    ''
        # nix
        if test -e /Users/jloos/.nix-profile/etc/profile.d/nix.sh
            fenv source /Users/jloos/.nix-profile/etc/profile.d/nix.sh
        end

        # home-manager
        set -gpx NIX_PATH "$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels"
    '';
  };

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
