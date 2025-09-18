{ config, pkgs, ... }:

{
  imports = [ ./home ];

  home.username = "cozygalvinism";
  home.homeDirectory = "/home/cozygalvinism";

  xdg.configFile."autostart/gnome-keyring-ssh.desktop" = {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=SSH Key Agent
      Hidden=true
    '';
  };

  home.packages = with pkgs; [
    gnome-tweaks
    kitty
    wezterm
    unstable.windsurf
    procps
    starship
    vesktop
    fzf
    spotify
    teams-for-linux
    libreoffice
    pre-commit
    bun
    nodejs
    deadbeef
  ];

  fonts.fontconfig.enable = true;

  programs.bun = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.vesktop = { enable = true; };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    enableGitIntegration = true;
    settings = {
      font_family = "CaskaydiaCove Nerd Font";
      font_size = "10.0";
    };
  };

  programs.git = {
    enable = true;
    userName = "cozyGalvinism";
    userEmail = "jean@der-capta.in";
    signing = {
      key = "0x958546AA073FAA66";
      signByDefault = true;
    };
    extraConfig = { init.defaultBranch = "develop"; };
  };

  programs.gpg = {
    enable = true;
    settings = {
      "keyid-format" = "0xlong";
      "with-fingerprint" = "";
      "with-keygrip" = "";
      "require-cross-certification" = "";
      "personal-digest-preferences" = "SHA512 SHA384 SHA256";
      "cert-digest-algo" = "SHA512";
      "default-preference-list" =
        "SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP";
      "use-agent" = "";
      "no-emit-version" = "";
      "no-comments" = "";
    };
    scdaemonSettings = { disable-ccid = true; };
    publicKeys = [{
      source = ./keys/cozy.asc;
      trust = "ultimate";
    }];
  };

  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    enableSshSupport = true;
    enableScDaemon = true;
    pinentry.package = pkgs.pinentry-gnome3;
    sshKeys = [ "FE6F161F1D9FEF2532F743054696F4C9FEEF6549" ];
  };

  dconf.enable = true;
  dconf.settings = {
    "org/gnome/Console" = {
      custom-font = "CaskaydiaCove Nerd Font 10";
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-theme = "Adwaita";
      icon-theme = "Adwaita";
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
      {
        name = "Open Terminal";
        command = "${pkgs.gnome-console}/bin/gnome-console";
        binding = "<Primary><Alt>T";
      };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        appindicator.extensionUuid
        dash-to-dock.extensionUuid
        gsconnect.extensionUuid
      ];
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "LEFT";
      multi-monitor = true;
    };
  };

  age = { identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ]; };

  home.stateVersion = "25.05";
}
