{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.cozyConfig.security.gpg;
in {
  options.cozyConfig.security.gpg = {
    enable = mkEnableOption "Enable GPG configuration";

    enableAgent = mkOption {
      type = types.bool;
      default = true;
      description = "Enable GPG agent";
    };

    enableSSHSupport = mkOption {
      type = types.bool;
      default = true;
      description = "Enable SSH support in GPG agent";
    };

    pinentryPackage = mkOption {
      type = types.package;
      default = pkgs.pinentry-gnome3;
      description = "Pinentry package to use";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        gnupg
        yubikey-manager
        yubikey-personalization
      ];
      description = "Extra packages to install";
    };
  };

  config = mkIf cfg.enable {
    programs.gnupg.agent = {
      enable = cfg.enableAgent;
      enableSSHSupport = cfg.enableSSHSupport;
      pinentryPackage = cfg.pinentryPackage;
    };

    services.pcscd.enable = true;

    environment.systemPackages = cfg.extraPackages;
  };
}
