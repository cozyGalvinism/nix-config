{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../.
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos";

  environment.systemPackages = with pkgs; [
    displaylink
  ];

  services.xserver.videoDrivers = [
    "displaylink"
  ];
  systemd.services.dlm.wantedBy = [ "multi-user.target" ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    extraModulePackages = [
      config.boot.kernelPackages.evdi
    ];
    initrd = {
      kernelModules = [
        "evdi"
      ];
    };
  };

  # System version
  system.stateVersion = "25.05";
}