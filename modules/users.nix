{ config, lib, pkgs, ... }:

with lib;

let
  defaultUser = {
    name = "cozygalvinism";
    description = "Default User";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      git
      gnupg
      pinentry-gnome3
    ];
    desktopEnvironment = "gnome";
  };

  mergeUserConfig = userCfg: defaultUser // userCfg;

  mkUser = userCfg: {
    users.users.${userCfg.name} = {
      isNormalUser = true;
      inherit (userCfg) description extraGroups;
      packages = userCfg.packages;
    };
  };
in {
  options.user = mkOption {
    type = types.attrsOf types.anything;
    default = {};
    description = "User configuration";
  };

  config = mkIf (config.user != {}) (
    mkUser (mergeUserConfig config.user)
  );
}
