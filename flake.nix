{
  description = "a system config";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
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

  outputs = inputs@{ nixpkgs, home-manager, agenix, xrdriver, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        system = "x86_64-linux";
      };
      modules = [
        ./configuration.nix

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
      ];
    };
  };
}
