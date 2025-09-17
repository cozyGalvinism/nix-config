{ config, lib, pkgs, ... }:

with lib;

let cfg = config.cozyConfig.locale;
in {
  options.cozyConfig.locale = {
    timeZone = mkOption {
      type = types.str;
      default = "Europe/Berlin";
      description = "System timezone";
    };

    defaultLocale = mkOption {
      type = types.str;
      default = "en_US.UTF-8";
      description = "Default system locale";
    };

    extraLocaleSettings = mkOption {
      type = types.attrsOf types.str;
      default = {
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
      description = "Extra locale settings";
    };

    consoleKeyMap = mkOption {
      type = types.str;
      default = "de-latin1-nodeadkeys";
      description = "Console keymap";
    };
  };

  config = {
    time.timeZone = cfg.timeZone;
    i18n.defaultLocale = cfg.defaultLocale;
    i18n.extraLocaleSettings = cfg.extraLocaleSettings;
    console.keyMap = cfg.consoleKeyMap;
  };
}
