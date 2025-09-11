{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../.
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # System version
  system.stateVersion = "25.05";
}