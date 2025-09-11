{
  description = "a system config";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
    };
    xrdriver = {
      url = "github:shymega/XRLinuxDriver/shymega/nix-flake-support";
    };
  };

  outputs = inputs@{ nixpkgs, unstable, home-manager, agenix, xrdriver, ... }:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    commonArgs = {
      inherit system inputs;
    };

    mkHost = hostName: extraModules: lib.nixosSystem {
      inherit system;
      specialArgs = commonArgs // { hostName = hostName;};
      modules = [
        ./hosts/${hostName}
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.cozygalvinism = { ... }: {
            imports = [
              ./home.nix
              inputs.agenix.homeManagerModules.default
            ];
          };
        }
        agenix.nixosModules.default
      ] ++ extraModules;
    };
  in {
    nixosConfigurations = {
      nixos = mkHost "nixos" [];
    };
  };
}
