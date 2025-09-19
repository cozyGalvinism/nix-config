{ config, pkgs, inputs, ... }:

{
  imports = [ ../modules ];

  cozyConfig = {
    desktop.gnome.enable = true;
    security = {
      ssh.enable = true;
      gpg.enable = true;
    };
    nix.allowUnfree = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  environment.systemPackages = with pkgs; [
    git
    inputs.agenix.packages."${pkgs.system}".default
    inputs.xrdriver.packages."${pkgs.system}".default
    python313
    rustup
    gcc
    age
    age-plugin-yubikey
    polychromatic
    home-manager
    fd
  ];

  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [
      22 # SSH
    ];
    allowedTCPPortRanges = [{
      from = 1714;
      to = 1764;
    } # KDE Connect/GSConnect
      ];

    allowedUDPPortRanges = [{
      from = 1714;
      to = 1764;
    } # KDE Connect/GSConnect
      ];
  };

  user = {
    name = "cozygalvinism";
    # description = real name... laaaaaame
    description = "cozyGalvinism";
    extraGroups = [ "networkmanager" "wheel" "docker" "plugdev" ];
    packages = with pkgs; [
      gnupg
      pinentry-gnome3
      yubikey-manager
      yubikey-personalization
    ];
  };

  environment.variables = { EDITOR = "nano"; };

  # Fonts
  fonts.packages = with pkgs; [ nerd-fonts.caskaydia-cove ];

  # Programs
  programs.firefox.enable = true;

  programs.evolution = {
    enable = true;
    plugins = [ pkgs.evolution-ews ];
  };
  services.gnome.evolution-data-server.enable = true;

  hardware.openrazer = {
    enable = true;
    users = [ "cozygalvinism" ];
    syncEffectsEnabled = true;
  };

  # Secrets
  age = {
    secrets = {
      "BONM.ovpn" = {
        file = ../secrets/BONM.ovpn.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };

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
  };

  # OpenVPN configuration
  environment.etc = {
    "openvpn/ca.crt".source = ../openvpn/ca.crt;
    "openvpn/client.crt".source = ../openvpn/client.crt;
  };

  services.openvpn.servers.BONM = {
    autoStart = false;
    config = "config ${config.age.secrets."BONM.ovpn".path}";
  };
}
