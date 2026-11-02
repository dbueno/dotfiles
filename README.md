# Dotfiles

This is my Home Manager configuration. `flake.nix` defines the flake inputs and
the available homes. The current macOS home uses a hashed hostname.

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
| `home-files/` | Files linked into the home directory by `nix/home/files.nix`. Paths mirror `$HOME`: `home-files/.config/git/config` becomes `~/.config/git/config`. A config built on `homeModules.default` links its own directories the same way by adding them to `dotfiles.homeFileDirs`. |
| `assets/` | Source files Nix reads or packages instead of linking directly. For example, Home Manager includes `assets/zsh/rc` in its generated `.zshrc`. Also holds editor sources and reference files under `assets/linux/`. |
| `scripts/` | Utilities. Some are packaged by Nix modules; others are standalone. Platform-specific utilities live under `scripts/osx/`. |

`flake.nix` and `flake.lock` stay at the repository root because they define the
flake. `.envrc` enables the development shell through direnv.

Only the modules listed in `homeModule` in `flake.nix` affect the Home Manager
build. Both `nix/hosts/mac.nix` and `nix/hosts/linux.nix` are among them; each
applies only on its own platform. The NixOS modules, the ThinkPad
configuration, and some files under `assets/` are kept for other machines or
reference.

The flake also exports `homeModules.default` (those modules) and
`lib.mkHomeConfig`, so another flake can build a home from this one with a
different username or home directory and its own modules layered on top.

### Per-machine hooks

A config built on `homeModules.default` can change these without copying
dotfiles' files:

| Option | Default | Effect |
| --- | --- | --- |
| `dotfiles.homeFileDirs` | `[ ./home-files ]` | More directories to link into `$HOME`; later ones replace files at the same path. |
| `dotfiles.loginShell.enable` | `true` | Sets `home.loginShell` to zsh for hm-login-shell-helper. Disable where the helper isn't installed. |
| `dotfiles.gui.enable` | `true` | Installs graphical applications. |
| `dotfiles.cdpath` | `~/work/inprogress`, `~/proj` | Directories `cd` searches (zsh `cdpath`, bash `CDPATH`). Entries add to the defaults; use absolute paths. |
| `dotfiles.python.dontCheckPackages` | `[ "dbf" ]` | python3 packages built without their tests. Entries add to the defaults. |

These files are read when present, so a config can add them through its own
`home-files/` directory:

| File | Read by |
| --- | --- |
| `~/.ssh/config.d/*` | ssh, before dotfiles' `Host *`, so its values win |
| `~/.config/git/config.local` | git, after dotfiles' config, so its values win |
| `~/.zshrc_local`, `~/.bashrc_local`, `~/.bash_profile_local` | zsh and bash |
| `~/.config/tmux/local.conf` | tmux, after dotfiles' config |
| `vimrc_local` on the runtime path | vim and neovim |

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

Zed is an exception to the usual linked-file rule. On activation,
`nix/home/zed.nix` copies `home-files/.config/zed/settings-home-manager.json` to
`~/.config/zed/settings.json` only if that destination does not exist. The copy
is writable, so Zed can edit it through its GUI; later Home Manager switches
leave it alone. Update the seed separately when you want new machines to start
with your latest preferences.

## Build and activate

From the repository root:

```sh
nix run .#switch
# Build without activating (substitute the host key from flake.nix):
home-manager build --flake 'path:.#dbueno@sha256-<digest>'
```

`nix run .#switch` does the `switch` for this machine's short hostname
(`uname -n` up to the first dot). It tries `<username>@<hostname>` first, then
`<username>@sha256-<digest>`, where the digest is the lowercase hexadecimal
SHA-256 of the short hostname with no trailing newline. Hostnames are
case-sensitive. To compute a key for `hosts` in `flake.nix` on macOS or Linux:

```sh
host=$(uname -n)
printf 'sha256-'; printf '%s' "${host%%.*}" | shasum -a 256 | cut -d ' ' -f 1
```

`nix run .#switch -- <host>` selects another host, accepting a hostname, a
`sha256-<digest>` key, or either prefixed with `<username>@`. Hostname arguments
also try the literal name before its hash. With no match, it offers this
system's homes to pick from (or fails with a list when input isn't a terminal).
Other arguments go to home-manager.

Hashes keep readable hostnames out of the current configuration, but someone
can still test guesses against them. Renaming an entry does not remove its
previous name from Git history.

Other flakes build homes the same way with `lib.mkHomeConfigurations`, which
takes a set of hosts keyed by short hostname or `sha256-<digest>`, `modules`
shared by all of them (typically `homeModules.default`), `extraSpecialArgs`
passed to all of them (each host's own win), and `defaults` for host
attributes a host doesn't set (e.g. `username`, `stateVersion`, `system`).
`homeDirectory` defaults to `/Users/<username>` on Darwin and
`/home/<username>` otherwise. They get the same `switch` app, and a `repl` app
that opens `nix repl` on the flake, with `apps = lib.mkSwitchApps self`.

`build` creates a generation without activating it. `switch` activates the
configuration on the intended host. Ask the user for explicit approval before
running `switch` or otherwise activating a new configuration; a request to edit
config files does not authorize activation. Use the configuration name in
`flake.nix` if it changes. `nix flake show` lists outputs; `nix fmt` formats Nix
files.
