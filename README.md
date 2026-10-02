# Dotfiles

This repository is a Nix flake for a Home Manager configuration. `flake.nix` defines inputs, the
package overlay, and host configurations; root `*.nix` files provide Home Manager modules. Put
custom package definitions in `pkgs/`, development environment modules in `development/`, and
host-specific settings in files such as `mac-host.nix` or `linux-host.nix`. Files in `dotfiles/` are
linked into the home directory by `dotfiles.nix`. Editor configuration lives in `config/nvim/`,
`dotvim/`, and `neovim/`; shell fragments live in `zsh/`. Keep standalone utilities in `scripts/` or
`automation/`. `xdg_config/` holds application configuration; check the relevant module before
assuming a new file there is linked automatically.

``home-manager build --flake 'path:.#dbueno@<hostname>'``

## Build, Test, and Development Commands

- `nix flake show` lists the flake's available outputs and checks evaluation.
- `nix fmt` formats the repository's Nix files with the flake's default formatter.
- `home-manager build --flake 'path:.#dbueno@NOTANYMORE'` builds the configured macOS home
  generation without activating it. Use the current configuration name from `flake.nix` if it
  changes.
- `home-manager switch --flake 'path:.#dbueno@NOTANYMORE'` activates the built configuration on the
  intended host; review changes before running it.

Run these commands from the repository root.

## Coding Style & Naming Conventions

Use `nix fmt` for Nix files. Keep descriptive lowercase module names, host wiring in `flake.nix`,
and feature settings in focused modules. Preserve the existing style in Lua, Vimscript, shell, and
Python files. Inspect the diff after formatting.
