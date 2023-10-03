{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage. 
  home.username = "mbellani";
  home.homeDirectory = "/home/mbellani";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # Allows installing unfree things like slack, 1password etc..
  nixpkgs.config.allowUnfree = true;

  # The home.packages option allows you to install Nix packages into your
  # environment
  home.packages = with pkgs; [
    # Browsers, one too many
    firefox
    vivaldi

    yubikey-manager-qt

    # Social
    slack
    signal-desktop
    zoom-us
    whatsapp-for-linux

    ## Editors
    #emacs
    vscode
    vim # TODO: remove once doom emacs is setup.

    # Shell/Terminal packages
    zsh
    starship
    alacritty
    ripgrep
    tmux
    bat
    wakeonlan
    jq
    jellyfin-ffmpeg

    # Development utils
    git
    docker

    # Other productvity utils
    _1password-gui
    obsidian

    # Nix tools
    nixfmt
    htop

    # NixGL related stuff
    glxinfo
    ## nixgl.nixGLIntel -- TODO: Fix this
    neofetch

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Manual sourcing of  `hm-session-vars` is not needed since i am managing my
  # shell (zsh in my case, not sure if that's true for other shells). `.zshenv`
  # generated by home-manager  already sources `~/.nix-profile/etc/profile.d/hm-session-vars.sh`.
  # TODO: These don't really work, need to fix. 
  home.sessionVariables = {
    EDITOR = "code";
    TERMINAL = "alacritty";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;

    # oh-my-zsh configuration
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };

    # Need this for rust development so that the things like openssl linking work.
    envExtra = ''
      export QT_XCB_GL_INTEGRATION=xcb_egl
    '';

    # aliases
    shellAliases = {
      # nixGL allows alacritty to discover GPU driver libs (e.g. mesa). Additional setup
      # is needed that's part of setup.sh. See issue: https://github.com/NixOS/nixpkgs/issues/122671.
      # alacritty = "nixGL alacritty";
      hms = "home-manager switch";
    };

  };

  programs.git = {
    enable = true;
    userName = "Manish Bellani";
    userEmail = "manish.bellani@gmail.com";
    lfs.enable = true;

    extraConfig = {
      merge.tool = "${pkgs.vscode}/bin/code";
      core.editor = "code";
      url = { "git@github.com:" = { insteadOf = "https://github.com"; }; };
    };

    ignores = [ ".direnv/" ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      battery = {
        full_symbol = "🔋 ";
        charging_symbol = "⚡️ ";
        discharging_symbol = "💀 ";
      };

      battery.display = [
        {
          threshold = 10;
          style = "bold red";
        }
        {
          threshold = 15;
          style = "red";
        }
        {
          threshold = 30;
          style = "bold yellow";
        }
        {
          threshold = 50;
          style = "yellow";
        }
        {
          threshold = 100;
          style = "bold green";
        }
      ];
    };

  };

  programs.alacritty = { enable = true; };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  xdg.desktopEntries.Alacritty = {
    type = "Application";
    exec = "nixGLIntel alacritty";
    icon = "Alacritty";
    terminal = false;
    name = "Alacritty";
    genericName = "Terminal";
    comment = "A fast, cross-platform, OpenGL terminal emulator";
  };

  xdg.desktopEntries.Zoom = {
    type = "Application";
    exec = "env QT_XCB_GL_INTEGRATION=xcb_egl nixGLIntel zoom";
    name = "Zoom";
    icon = "Zoom";
  };
  # Allow gnome to see applications installed via home-manager
  targets.genericLinux.enable = true;

}
