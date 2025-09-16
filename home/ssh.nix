{ config, lib, pkgs, ... }: {
  services.ssh-agent.enable = false;

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        user = "git";
      };

      "git.hadron.eu.com" = {
        user = "git";
      };
    };
  };
}