{ config, lib, pkgs, ... }: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -e SSH_AGENT_PID
      set -x GPG_TTY (tty)
      set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
    '';

    shellAliases = {
      hm = "home-manager";
    };
    generateCompletions = true;

    plugins = [
      { name = "plugin-git"; src = pkgs.fishPlugins.plugin-git.src; }
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      {
        name = "odoo.fish";
        src = pkgs.fetchFromGitHub {
          owner = "cozyGalvinism";
          repo = "odoo.fish";
          rev = "e9f0b36c0073e98f8c020e49e31c822c492390d3";
          sha256 = "sha256-VUoXtJTmAK8yQzgHWA0AVcrb6xavlr4ZAhwOig/vRNo=";
        };
      }
    ];
  };
}