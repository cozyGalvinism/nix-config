{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.cozyConfig.nix;
in {
  options.cozyConfig.nix = {
    enableFlakes = mkOption {
      type = types.bool;
      default = true;
      description = "Enable flakes and nix-command features";
    };

    extraExperimentalFeatures = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra experimental features to enable";
    };

    allowUnfree = mkOption {
      type = types.bool;
      default = true;
      description = "Allow unfree packages";
    };
  };

  config = {
    nixpkgs.config.allowUnfree = cfg.allowUnfree;
    nix.settings.experimental-features =
      (if cfg.enableFlakes then ["nix-command" "flakes"] else []) ++ cfg.extraExperimentalFeatures;
  };
}