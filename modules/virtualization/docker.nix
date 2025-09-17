{ config, lib, pkgs, ... }: {
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    daemon.settings.live-restore = true;
  };
}
