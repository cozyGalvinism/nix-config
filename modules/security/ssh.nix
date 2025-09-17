{ config, lib, pkgs, ... }:

with lib;

let cfg = config.cozyConfig.security.ssh;
in {
  options.cozyConfig.security.ssh = {
    enable = mkEnableOption "Enable SSH configuration";

    enableServer = mkOption {
      type = types.bool;
      default = true;
      description = "Enable SSH server";
    };

    startAgent = mkOption {
      type = types.bool;
      default = false;
      description = "Start SSH agent (set to false when using gpg-agent)";
    };

    extraConfig = mkOption {
      type = types.attrs;
      default = { };
      description = "Extra SSH server configuration";
    };
  };

  config = mkIf cfg.enable {
    services.openssh =
      mkIf cfg.enableServer ({ enable = true; } // cfg.extraConfig);

    programs.ssh.startAgent = cfg.startAgent;
  };
}
