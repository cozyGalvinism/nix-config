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
    "editor.fontFamily" = "CaskaydiaCove Nerd Font";
    "editor.fontSize" = 12;
  };

  mkProfile = { extraExtensions ? [ ], extraSettings ? { }, extraAttrs ? { }, writeSettings ? true } : {
    extensions = commonExtensions ++ extraExtensions;
  }
  // lib.optionalAttrs writeSettings {
    userSettings = commonSettings // extraSettings;
  } // extraAttrs;

  profileIds = builtins.attrNames (config.programs.vscode.profiles or {});
  profilesRegistry = builtins.toJSON {
    profiles = map (n: { name = n; id = n; }) profileIds;
    lastActiveProfile = "default";
    profileAssociations = { };
  };

  profileBaseSettings = {
    rust = commonSettings // { };
  };

  profileSecretInjections = [
    {
      profile = "rust";
      items = [
        { key = "codestats.apikey"; secret = "codestats.apikey"; }
        { key = "wakatime.apiKey"; secret = "wakatime.apikey"; }
      ];
    }
  ];
in {
  age.secrets = {
    "codestats.apikey" = {
      file = ../secrets/codestats.apikey.age;
    };
    "wakatime.apikey" = {
      file = ../secrets/wakatime.apikey.age;
    };
  };

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
        writeSettings = false;
        extraExtensions = with openvsx; [
          rust-lang.rust-analyzer
          tamasfe.even-better-toml
          fill-labs.dependi
          gruntfuggly.todo-tree
          wayou.vscode-todo-highlight
          wakatime.vscode-wakatime
          codestats.code-stats-vscode
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

  home.activation.injectWindsurfSecrets = lib.hm.dag.entryAfter [ "seedWindsurfProfiles" ] (
    let
      mkSnippet = inj: ''
        profiles_dir="$HOME/.config/Windsurf/User/profiles"
        settings="$profiles_dir/${inj.profile}/settings.json"
        mkdir -p "$(dirname "$settings")"
        tmp_file="$(mktemp)"
        # Start from the Nix-defined base settings for this profile (or empty)
        cat > "$tmp_file" <<'JSON'
${builtins.toJSON (profileBaseSettings.${inj.profile} or {})}
JSON
'' + (lib.concatStringsSep "\n" (map (it: ''
        if [ -r "${config.age.secrets.${it.secret}.path}" ]; then
          val="$(tr -d '\n' < "${config.age.secrets.${it.secret}.path}")"
          new_file="$(mktemp)"
          ${pkgs.jq}/bin/jq --arg v "$val" '. + {"${it.key}": $v}' "$tmp_file" > "$new_file"
          mv "$new_file" "$tmp_file"
        fi
'' ) inj.items)) + ''
        chmod 600 "$tmp_file"
        mv "$tmp_file" "$settings"
'';
    in
      ''
        set -eu
      '' + (lib.concatStringsSep "\n" (map mkSnippet profileSecretInjections))
  );
}