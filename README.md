# NixOS Configuration (Private)

**NOTE**: This README is not regularly updated!

This repository contains my personal NixOS and Home Manager configuration, using flakes and agenix for secret management.

Key files and directories:
- `flake.nix` — main entry point; defines inputs and builds `nixosConfigurations` via `mkHost`.
- `hosts/` — host-specific configurations.
  - `hosts/default.nix` — common system config imported by each host.
  - `hosts/<name>/` — per-host directory with `default.nix` and `hardware-configuration.nix`.
- `modules/` — modularized system configuration.
- `home.nix` — Home Manager configuration for user `cozygalvinism`.
- `secrets/` — `agenix`-encrypted secrets (`*.age`) and `secrets/secrets.nix` recipient mapping.
- `openvpn/` — OpenVPN config and certs.
- `keys/` — GPG keys for git signing, etc.

The configuration integrates Home Manager through the NixOS module and uses `gpg-agent` for SSH authentication (not `gnome-keyring`). The GNOME keyring SSH component is disabled, and its autostart desktop file is hidden.

---

## Day-to-day commands

All commands assume you are in the repo root.

- Update inputs (flakes):
  ```bash
  nix flake update
  ```

- Build and switch locally (current host):
  ```bash
  sudo nixos-rebuild switch --flake .#nixos
  # Replace nixos with your host name if different
  ```

- Test without making it default (good for risky changes):
  ```bash
  sudo nixos-rebuild test --flake .#<host>
  ```

- Build only, to inspect or copy to remote:
  ```bash
  nix build .#nixosConfigurations.<host>.config.system.build.toplevel
  ```

- Roll back to previous generation:
  ```bash
  sudo nixos-rebuild switch --rollback
  # or at boot via the systemd-boot menu
  ```

- Garbage collect old generations and store paths:
  ```bash
  sudo nix-collect-garbage -d
  sudo nix store gc
  ```

- Show system generations:
  ```bash
  sudo nix-env -p /nix/var/nix/profiles/system --list-generations
  ```

- Diff current vs. built system (requires nvd):
  ```bash
  nix run nixpkgs#nvd -- diff /run/current-system result
  ```

Home Manager is integrated via `home-manager.nixosModules.home-manager` in `flake.nix`, so no separate `home-manager switch` is usually needed. If you do make purely HM changes and want a quick apply without touching system modules, you can still run:
```bash
home-manager switch --flake .#cozygalvinism@nixos
```
…but prefer full `nixos-rebuild switch` for consistency.

---

## Adding a new system (host)

1) Create the host directory:
```bash
mkdir -p hosts/<new-host>
```

2) Generate or copy the hardware configuration on the target machine:
- On the new machine, after installing a minimal NixOS, generate the hardware file:
  ```bash
  sudo nixos-generate-config
  cat /etc/nixos/hardware-configuration.nix > hardware-configuration.nix
  ```
  Copy that file into `hosts/<new-host>/hardware-configuration.nix` in this repo.

3) Create `hosts/<new-host>/default.nix` similar to `hosts/nixos/default.nix`:
```nix
{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ../.
    ./hardware-configuration.nix
  ];

  networking.hostName = "<new-host>";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.05"; # set appropriately
}
```

4) Add the host to `flake.nix` under `nixosConfigurations` by using the helper `mkHost`:
```nix
# flake.nix (excerpt)
{
  outputs = inputs@{ nixpkgs, unstable, nix-vscode-extensions, home-manager, agenix, xrdriver, ... }:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    commonArgs = { inherit system inputs; };
    mkHost = hostName: extraModules: lib.nixosSystem {
      inherit system;
      specialArgs = commonArgs // { hostName = hostName; };
      modules = [
        ./hosts/${hostName}
        home-manager.nixosModules.home-manager { /* … */ }
        agenix.nixosModules.default
      ] ++ extraModules;
    };
  in {
    nixosConfigurations = {
      nixos = mkHost "nixos" [];
      <new-host> = mkHost "<new-host>" [];
    };
  };
}
```

5) Build/switch on the new machine:
```bash
sudo nixos-rebuild switch --flake .#<new-host>
```

Optional: remote deploy from a builder machine (ensure SSH works):
```bash
sudo nixos-rebuild switch --flake .#<new-host> --target-host root@<new-host> --build-host localhost
```

---

## Secrets management with agenix

- Encrypted secrets live in `secrets/*.age`.
- Recipient mapping lives in `secrets/secrets.nix`.
- Decryption/placement is wired in `hosts/default.nix` via `age.secrets` and `environment.etc` for OpenVPN files.

Common operations:

- Edit a secret (prompts your editor and re-encrypts on save):
  ```bash
  nix shell nixpkgs#agenix -c agenix -e secrets/BONM.userpass.age
  ```

- Rekey all secrets after changing recipients:
  ```bash
  nix shell nixpkgs#agenix -c agenix -r
  ```

- Get a YubiKey identity:
  ```bash
  nix shell -p age -p age-plugin-yubikey
  age-plugin-yubikey --identity > secrets/identities/yubikey.txt
  ```

### Add a new system recipient (host)

1) Obtain the host's SSH ed25519 public key (host key), usually at:
```bash
cat /etc/ssh/ssh_host_ed25519_key.pub
# Example format: ssh-ed25519 AAAA... root@<host>
```

2) Add it to `secrets/secrets.nix`. This repo uses a `systems` list; add the new key there, or per-secret if you want finer control. Example:
```nix
let
  nixtop = "ssh-ed25519 AAAA... root@nixos";
  newhost = "ssh-ed25519 AAAA... root@<new-host>";
  systems = [ nixtop newhost ];
in {
  "BONM.key.age".publicKeys = systems;
  "BONM.userpass.age".publicKeys = systems;
}
```

3) Rekey the secrets:
```bash
nix shell nixpkgs#agenix -c agenix -r
```

4) Rebuild on the target host; `agenix` will decrypt to the paths specified in `age.secrets`.

### Add a new human recipient

You can also add personal keys so your user can decrypt/edit secrets locally.

- Using an SSH ed25519 public key:
  ```bash
  cat ~/.ssh/id_ed25519.pub
  ```
- Or create an age key pair:
  ```bash
  nix shell nixpkgs#age -c age-keygen -o ~/.config/age/keys.txt
  # Public key will be printed; add it to secrets/secrets.nix
  ```

Add the public key value to `secrets/secrets.nix` (e.g., a `users` list), include that list in the relevant `.publicKeys`, and then run `agenix -r`.

---

## OpenVPN note

- OpenVPN files are stored in `openvpn/` and linked into `/etc/openvpn/` via `environment.etc` in `hosts/default.nix`.
- The `BONM` profile can be controlled via the `services.openvpn.servers.BONM` option.

---

## GNOME keyring and GPG agent

- SSH authentication is handled by `gpg-agent` with `EnableSshSupport = true` in `home.nix`.
- The GNOME keyring SSH component is intentionally disabled, and `gnome-keyring-ssh.desktop` is hidden via `home.nix` to avoid conflicts.

---

## Tips

- After big updates, consider rebooting to ensure all services pick up the new generation.
- If a rebuild fails, try `nix store gc` and rebuild, or use `--fallback` when substituters are flaky.
- Keep `system.stateVersion` pinned to the actual installed release to avoid unintended defaults changing.
