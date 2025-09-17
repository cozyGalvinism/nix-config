{
  description = "cozy's absolutely amazing system config for nixos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = { url = "github:ryantm/agenix"; };
    xrdriver = {
      url = "github:shymega/XRLinuxDriver/shymega/nix-flake-support";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
    };
    nixvim = { url = "github:nix-community/nixvim/nixos-25.05"; };
  };

  outputs = inputs@{ nixpkgs, unstable, nix-vscode-extensions, home-manager
    , agenix, xrdriver, nixvim, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      commonArgs = { inherit system inputs; };
      defaultOverlays = import ./overlays;

      hmPkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          defaultOverlays
          nix-vscode-extensions.overlays.default
          (final: prev: {
            unstable = import inputs.unstable {
              system = prev.stdenv.hostPlatform.system;
              config = prev.config;
            };
          })
        ];
      };

      hmCommon = { ... }: {
        imports = [
          ./home.nix
          inputs.agenix.homeManagerModules.default
          inputs.nixvim.homeModules.nixvim
        ];
      };

      mkHost = hostName: extraModules:
        lib.nixosSystem {
          inherit system;
          specialArgs = commonArgs // { hostName = hostName; };
          modules = [
            ./hosts/${hostName}

            ({ ... }: {
              nixpkgs = {
                config.allowUnfree = true;
                overlays = [
                  defaultOverlays
                  nix-vscode-extensions.overlays.default
                  (final: prev: {
                    unstable = import inputs.unstable {
                      system = prev.stdenv.hostPlatform.system;
                      config = prev.config;
                    };
                  })
                ];
              };
            })

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.cozygalvinism = hmCommon;
            }
            agenix.nixosModules.default
          ] ++ extraModules;
        };
    in {
      nixosConfigurations = { nixos = mkHost "nixos" [ ]; };

      homeConfigurations."cozygalvinism@nixos" =
        home-manager.lib.homeManagerConfiguration {
          pkgs = hmPkgs;
          modules = [ hmCommon ];
          extraSpecialArgs = commonArgs // { hostName = "nixos"; };
        };

      devShells.${system}.default =
        let pkgs = import nixpkgs { inherit system; };
        in pkgs.mkShell {
          packages = with pkgs; [ nixd nixfmt statix ];

          shellHook = ''
            echo "nixd: $(nixd --version)"
            echo "nixfmt: $(nixfmt --version)"
            echo "statix: $(statix --version)"
          '';
        };
    };
}
