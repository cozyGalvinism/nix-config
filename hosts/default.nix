{ config, pkgs, lib, inputs, hostName, ... }:

{
  imports = [
    ../modules/users.nix
  ];

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    git
    inputs.agenix.packages."${pkgs.system}".default
    inputs.xrdriver.packages."${pkgs.system}".default
  ];

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Desktop environment
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb = {
      layout = "de";
      variant = "nodeadkeys";
    };
  };

  services.gnome = {
    games.enable = false;
  };

  services.printing.enable = true;

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  console.keyMap = "de-latin1-nodeadkeys";

  user = {
    name = "cozygalvinism";
    description = "Default User";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      gnupg
      pinentry-gnome3
      yubikey-manager
      yubikey-personalization
    ];
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  services.openssh.enable = true;
  programs.ssh.startAgent = false;
  services.pcscd.enable = true;

  environment.variables = {
    EDITOR = "nano";
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
  ];

  # Programs
  programs.firefox.enable = true;
  programs.dconf.enable = true;
  
  # Services
  services.udev.packages = [ pkgs.gnome-settings-daemon ];

  # Overlays
  nixpkgs.overlays = [
    (final: prev: {
      gnome-keyring = prev.gnome-keyring.overrideAttrs (oldAttrs: {
        mesonFlags = (lib.filter (flag: flag != "-Dssh-agent=true") oldAttrs.mesonFlags) ++ [
          "-Dssh-agent=false"
        ];
      });
    })
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

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