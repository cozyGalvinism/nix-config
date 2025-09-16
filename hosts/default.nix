{ config, pkgs, lib, inputs, hostName, ... }:

let
  yubikeyIdentity = "/var/lib/age-identities/yubikey.txt";
  exe = lib.getExe pkgs.age-plugin-yubikey;

  genScript = pkgs.writeShellScript "yubikey-age-identity.sh" ''
    set -euo pipefail
    install -d -m 0755 /var/lib/age-identities

    # Try to read the identity descriptor from the YubiKey
    if ${exe} -i > /tmp/yubi.id 2> /tmp/yubi.err; then
      install -m 0444 -o root -g root /tmp/yubi.id ${yubikeyIdentity}
    else
      echo "[yubikey-age-identity] age-plugin-yubikey failed; keeping previous identity if any"
      [ -s ${yubikeyIdentity} ] || exit 0
    fi
  '';
in {
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
    python313
    rustup
    gcc
    age
    age-plugin-yubikey
    polychromatic
  ];

  networking.networkmanager.enable = true;

  user = {
    name = "cozygalvinism";
    # description = real name... laaaaaame
    description = "cozyGalvinism";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
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

  programs.evolution = {
    enable = true;
    plugins = [
      pkgs.evolution-ews
    ];
  };
  services.gnome.evolution-data-server.enable = true;

  hardware.openrazer = {
    enable = true;
    users = [ "cozygalvinism" ];
    syncEffectsEnabled = true;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/age-identities 0700 root root -"
  ];

  systemd.services."yubikey-age-identity" = {
    description = "Generate age identity from YubiKey";
    wantedBy = [ "multi-user.target" ];
    after = [ "pcscd.service" "smartcard.target" ];
    requires = [ "pcscd.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = genScript;
    };
  };

  # Secrets
  age = {
    ageBin = "PATH=${pkgs.age-plugin-yubikey}/bin:$PATH ${pkgs.age}/bin/age";
    identityPaths = [
      yubikeyIdentity
    ] ++ map (e: e.path) (
      lib.filter (e: e.type == "rsa" || e.type == "ed25519") config.services.openssh.hostKeys
    );
    secrets = {
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
    "openvpn/BONM.conf".source = ../openvpn/BONM.ovpn;
  };

  services.openvpn.servers.BONM = {
    autoStart = false;
    config = "config /etc/openvpn/BONM.conf";
  };
}
