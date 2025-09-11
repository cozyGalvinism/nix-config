{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.cozyConfig.desktop.gnome;

in {
  options.cozyConfig.desktop.gnome = {
    enable = mkEnableOption "Enable GNOME desktop environment";
  };

  config = mkIf cfg.enable {
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
      gnome-keyring.enable = true;
    };

    services.printing.enable = true;

    programs.dconf.enable = true;

    services.udev.packages = [ pkgs.gnome-settings-daemon ];

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    nixpkgs.overlays = [
      (final: prev: {
        gnome-keyring = prev.gnome-keyring.overrideAttrs (oldAttrs: {
          mesonFlags = (lib.filter (flag: flag != "-Dssh-agent=true") oldAttrs.mesonFlags) ++ [
            "-Dssh-agent=false"
          ];
        });
      })
    ];
  };
}