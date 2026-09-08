# NixOS Config

System configuration for host `nixos`, managed with Nix flakes-free `configuration.nix`.

## Layout

- `configuration.nix` — main system configuration
- `hardware-configuration.nix` — auto-generated hardware scan, don't edit by hand

## Highlights

- KDE Plasma 6 desktop, SDDM display manager
- PipeWire audio, NetworkManager
- Docker enabled, user `hisham` in `wheel`, `networkmanager`, `docker` groups
- Fish as default user shell
- Timezone: `Asia/Muscat`

## Usage

```sh
sudo nixos-rebuild switch
```

after editing `configuration.nix`.
