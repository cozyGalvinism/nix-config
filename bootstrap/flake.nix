{
  description = "Bootstrap age-plugin-yubikey identity";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  outputs = { self, nixpkgs }:
  let
    systems = [ "x86_64-linux" "aarch64-linux" ];
    forAll = f: nixpkgs.lib.genAttrs systems (system:
    let pkgs = import nixpkgs { inherit system; };
    in f pkgs);
  in {
    apps = forAll (pkgs:
      let
        app = pkgs.writeShellApplication {
          name = "bootstrap-yubikey-age";
          runtimeInputs = [
            pkgs.bash
            pkgs.coreutils
            pkgs.systemd
            pkgs.age-plugin-yubikey
            pkgs.age
          ];
          text = ''
            #!/usr/bin/env bash
            set -euo pipefail

            DEST=''${DEST:-"/var/lib/age-identities/yubikey.txt"}
            MODE=''${MODE:-"0444"}
            FORCE=''${FORCE:-"0"}
            NO_START=''${NO_START:-""}

            while [[ $# -gt 0 ]]; do
              case "$1" in
                --dest|--path) DEST="$2"; shift 2;;
                --mode) MODE="$2"; shift 2;;
                --force) FORCE=1; shift;;
                --no-start-pcscd) NO_START=1; shift;;
                -h|--help)
                  cat <<EOF
Usage: bootstrap-yubikey-age [--dest PATH] [--mode MODE] [--force] [--no-start-pcscd]
Defaults: PATH=/var/lib/age-identities/yubikey.txt MODE=0444
EOF
                  exit 0;;
                *) echo "Unknown arg: $1" >&2; exit 1;;
              esac
            done

            if [[ "$DEST" = /var/* ]] && [[ "$(id -u)" -ne 0 ]]; then
              echo "Elevating to write $DEST …"
              args=( --dest "$DEST" --mode "$MODE" )
              [[ "$FORCE" = "1" ]] && args+=( --force )
              [[ -n "$NO_START" ]] && args+=( --no-start-pcscd )
              exec sudo -E "$0" "''${args[@]}"
            fi

            mkdir -p "$(dirname "$DEST")"

            if [[ -z "$NO_START" ]] && command -v systemctl >/dev/null 2>&1; then
              systemctl start pcscd.service || true
            fi

            if [[ -s "$DEST" && "$FORCE" != "1" ]]; then
              echo "Identity already exists at $DEST (use --force to overwrite)."
              exit 0
            fi

            TMP="$(mktemp)"
            trap 'rm -f "$TMP" "$TMP.err"' EXIT

            if ! age-plugin-yubikey -i >"$TMP" 2>"$TMP.err"; then
              echo "age-plugin-yubikey failed. Is your YubiKey inserted? See $TMP.err" >&2
              exit 1
            fi

            install -m "$MODE" "$TMP" "$DEST"
            if command -v chown >/dev/null 2>&1; then
              chown root:root "$DEST" || true
            fi

            echo "Identity written to $DEST"
          '';
        };
      in {
        default = {
          type = "app";
          program = "${app}/bin/bootstrap-yubikey-age";
        };
        bootstrap-yubikey-age = {
          type = "app";
          program = "${app}/bin/bootstrap-yubikey-age";
        };
      }
    );
  };
}