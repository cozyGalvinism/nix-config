{ config, pkgs, ... }:

{
  imports = [ ../. ./hardware-configuration.nix ];

  networking.hostName = "nixos";

  environment.systemPackages = with pkgs; [ displaylink ];

  services.xserver.videoDrivers = [ "displaylink" ];
  systemd.services.dlm.wantedBy = [ "multi-user.target" ];

  boot = {
    kernelParams = [ "usbcore.autosuspend=-1" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    extraModulePackages = [ config.boot.kernelPackages.evdi ];
    initrd = { kernelModules = [ "evdi" ]; };
  };

  # System version
  system.stateVersion = "25.05";
}
