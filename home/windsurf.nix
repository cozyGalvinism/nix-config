{ config, lib, pkgs, ... }:

let
  openvsx = pkgs.nix-vscode-extensions.open-vsx;
  
  commonExtensions = [
    openvsx.kylinideteam.gitlens
  ];
  commonSettings = {
    "workbench.startupEditor" = "none";
    "workbench.welcomePage.enabled" = false;
    "workbench.welcomePage.walkthroughs.openOnInstall" = false;
  };

  mkProfile = { extraExtensions ? [ ], extraSettings ? { }, extraAttrs ? { } } : {
    extensions = commonExtensions ++ extraExtensions;
    userSettings = commonSettings // extraSettings;
  } // extraAttrs;

  profileIds = builtins.attrNames (config.programs.vscode.profiles or {});
  profilesRegistry = builtins.toJSON {
    profiles = map (n: { name = n; id = n; }) profileIds;
    lastActiveProfile = "default";
    profileAssociations = { };
  };
in {
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.windsurf;
    profiles = {
      default = mkProfile {
        extraAttrs = {
          enableExtensionUpdateCheck = true;
        };
      };

      nix = mkProfile {
        extraExtensions = [
          openvsx.jnoortheen.nix-ide
        ];
      };

      rust = mkProfile {
        extraExtensions = [
          openvsx.rust-lang.rust
        ];
      };

      odoo = mkProfile {
        extraExtensions = with openvsx; [
          ms-python.python
          magicstack.magicpython
          codeium.windsurfpyright
          redhat.vscode-xml
        ];
      };
    };
  };

  # Seed Windsurf profiles registry on first activation if it's missing,
  # and ensure the extensions directory exists and is writable.
  home.activation.seedWindsurfProfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -eu
    profiles_dir="$HOME/.config/Windsurf/User/profiles"
    mkdir -p "$profiles_dir"
    if [ ! -f "$profiles_dir/profiles.json" ]; then
      cat > "$profiles_dir/profiles.json" <<JSON
${profilesRegistry}
JSON
    fi
  '';
}