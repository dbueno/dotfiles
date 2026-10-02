# Dotfiles

This is my Home Manager configuration. `flake.nix` defines the flake inputs and
the available homes. At present it exposes `dbueno@NOTANYMORE` for macOS.

## Configuration design

Write configuration in each application's native format whenever practical.
For example, keep Git settings in `home-files/.config/git/config` instead of
expressing them as Nix attributes. Use Nix to link those files. Generate
configuration with Nix only when it must refer to Nix state or genuinely needs
programmatic variation.

## Repository layout

Nix expressions go in `nix/`; files installed unchanged go in `home-files/`;
other source files go in `assets/` or `scripts/`.

| Directory | Purpose |
| --- | --- |
| `nix/home/` | Home Manager modules for applications and features. `default.nix` is the general package module; `shell.nix` imports several other modules. |
| `nix/hosts/` | Host and platform settings. `flake.nix` selects the modules used by each configured home. |
| `nix/development/` | Language and development environment modules. |
| `nix/fonts/` | Font modules used by platform configurations. |
| `nix/pkgs/` | Custom package definitions and package-related modules. |
| `nix/nixos/thinkpad/` | A separate NixOS machine configuration; it is not a flake output. |
| `home-files/` | Files linked into the home directory by `nix/home/files.nix`. Paths mirror `$HOME`: `home-files/.config/git/config` becomes `~/.config/git/config`. |
| `assets/` | Source files Nix reads or packages instead of linking directly. For example, Home Manager includes `assets/zsh/rc` in its generated `.zshrc`. Also holds editor sources and reference files under `assets/linux/` and `assets/tmux/`. |
| `scripts/` | Utilities. Some are packaged by Nix modules; others are standalone. Platform-specific utilities live under `scripts/osx/`. |

`flake.nix` and `flake.lock` stay at the repository root because they define the
flake. `.envrc` enables the development shell through direnv.

Only the modules listed for `dbueno@NOTANYMORE` in `flake.nix` affect the current
Home Manager build. The Linux and NixOS modules, the ThinkPad configuration, and
some files under `assets/` are kept for other machines or reference. In
particular, `assets/tmux/macosx.conf` is not installed by Home Manager.

### Where to add something

- For a new Home Manager option or application, add a focused module in
  `nix/home/` and include it in `flake.nix` or import it from another module.
- For host-specific settings, edit the appropriate file in `nix/hosts/` and
  check the host's module list in `flake.nix`.
- For an unchanged file at a home path, add it at that path under `home-files/`.
  Files there are linked automatically, including files under `.config/`.
- For content embedded in a generated config or packaged as an editor plugin,
  put it under the relevant application in `assets/` and reference it from a Nix
  module. `assets/` files are not installed automatically.
- For an executable utility, add it to `scripts/`. Reference it from a Nix
  module if Home Manager should install it.

## Build and activate

From the repository root:

```sh
home-manager build --flake 'path:.#dbueno@NOTANYMORE'
home-manager switch --flake 'path:.#dbueno@NOTANYMORE'
```

`build` creates a generation without activating it. `switch` activates the
configuration on the intended host. Use the configuration name in `flake.nix`
if it changes. `nix flake show` lists outputs; `nix fmt` formats Nix files.
