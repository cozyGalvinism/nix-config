let
  nixtop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJL6avT3C+BPzyxaYFXnP97D0A/x/BwK8ynDqYM3p7pK root@nixos";
  systems = [ nixtop ];
in {
  "BONM.key.age".publicKeys = systems;
  "BONM.userpass.age".publicKeys = systems;
}