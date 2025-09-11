{ config, pkgs, lib, inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.unstable {
        system = pkgs.system;
        config = config.nixpkgs.config;
      };
    })
  ];
}