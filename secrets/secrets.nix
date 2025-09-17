let
  machines = {
    nixtop =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJL6avT3C+BPzyxaYFXnP97D0A/x/BwK8ynDqYM3p7pK root@nixos";
  };
in {
  "BONM.key.age".publicKeys = [ machines.nixtop ];
  "BONM.userpass.age".publicKeys = [ machines.nixtop ];
  "BONM.ovpn.age".publicKeys = [ machines.nixtop ];
  "codestats.apikey.age".publicKeys = [ machines.nixtop ];
  "wakatime.apikey.age".publicKeys = [ machines.nixtop ];
}
