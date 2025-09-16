let
  machines = {
    nixtop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJL6avT3C+BPzyxaYFXnP97D0A/x/BwK8ynDqYM3p7pK root@nixos";
  };

  users = {
    minikey = "age1yubikey1qd0zk0vv27m780sk77pn8uv8xnjknct46yk6dcpmlxdvaq47fj9yyme5xd0";
    bigkey = "age1yubikey1qdenwf5gew0k2d609qq4gjzkm7y89nfyth0xrlgju3es3mdnqanpjvzkrxh";
  };
in {
  "BONM.key.age".publicKeys = [ machines.nixtop users.minikey users.bigkey ];
  "BONM.userpass.age".publicKeys = [ machines.nixtop users.minikey users.bigkey ];
  "BONM.ovpn.age".publicKeys = [ machines.nixtop users.minikey users.bigkey ];
  "codestats.apikey.age".publicKeys = [ machines.nixtop users.minikey users.bigkey ];
  "wakatime.apikey.age".publicKeys = [ machines.nixtop users.minikey users.bigkey ];
}