{ config, pkgs, lib, inputs, hostName, ... }:

{
  imports = [
    ../modules
  ];

  cozyConfig = {
    desktop.gnome.enable = true;
    security = {
      ssh.enable = true;
      gpg.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    git
    inputs.agenix.packages."${pkgs.system}".default
    inputs.xrdriver.packages."${pkgs.system}".default
  ];

  networking.networkmanager.enable = true;

  user = {
    name = "cozygalvinism";
    # description = real name... laaaaaame
    description = "cozyGalvinism";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      gnupg
      pinentry-gnome3
      yubikey-manager
      yubikey-personalization
    ];
  };

  environment.variables = {
    EDITOR = "nano";
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
  ];

  # Programs
  programs.firefox.enable = true;

  # Secrets
  age.secrets = {
    "BONM.key" = {
      file = ../secrets/BONM.key.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };

    "BONM.userpass" = {
      file = ../secrets/BONM.userpass.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };

  # OpenVPN configuration
  environment.etc = {
    "openvpn/ca.crt".source = ../openvpn/ca.crt;
    "openvpn/client.crt".source = ../openvpn/client.crt;
    "openvpn/BONM.conf".source = ../openvpn/BONM.ovpn;
  };

  services.openvpn.servers.BONM = {
    autoStart = false;
    config = "config /etc/openvpn/BONM.conf";
  };
}