{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
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

  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
  ];

  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.gnome = {
    games.enable = false;
  };

  services.xserver.xkb = {
    layout = "de";
    variant = "nodeadkeys";
  };

  console.keyMap = "de-latin1-nodeadkeys";

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };
  nix.settings.experimental-features = ["nix-command" "flakes"];

  users.users.cozygalvinism = {
    isNormalUser = true;
    description = "cozyGalvinism";
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

  programs.firefox.enable = true;
  programs.dconf.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    gnomeExtensions.appindicator
    gnome-themes-extra
    inputs.agenix.packages."${system}".default
    inputs.xrdriver.packages."${system}".default
  ];

  services.udev.packages = [ pkgs.gnome-settings-daemon ];

  environment.variables = {
    EDITOR = "nano";
  };

  nixpkgs.overlays = [
    (final: prev: {
      gnome-keyring = prev.gnome-keyring.overrideAttrs (oldAttrs: {
        mesonFlags = (builtins.filter (flag: flag != "-Dssh-agent=true") oldAttrs.mesonFlags) ++ [
          "-Dssh-agent=false"
        ];
      });
    })
  ];

  services.openssh.enable = true;
  programs.ssh.startAgent = false;
  services.pcscd.enable = true;

  age.secrets = {
    "BONM.key" = {
      file = ./secrets/BONM.key.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };

    "BONM.userpass" = {
      file = ./secrets/BONM.userpass.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };

  environment.etc."openvpn/ca.crt".source = ./openvpn/ca.crt;
  environment.etc."openvpn/client.crt".source = ./openvpn/client.crt;
  environment.etc."openvpn/BONM.conf".source = ./openvpn/BONM.ovpn;

  services.openvpn.servers.BONM = {
    autoStart = false;
    config = "config /etc/openvpn/BONM.conf";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05";

}

