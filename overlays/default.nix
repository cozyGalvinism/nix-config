final: prev:
let
  files = builtins.attrNames (builtins.readDir ./.);
  overlayFiles = builtins.filter (name:
    name != "default.nix" && builtins.match ".*\\.nix" name != null
  ) files;

  imported = map (name: import (./. + "/${name}")) overlayFiles;

  composed = builtins.foldl' (acc: o:
    final2: prev2: acc final2 prev2 // (o final2 prev2)
  ) (_: _: {}) imported;
in
composed final prev
