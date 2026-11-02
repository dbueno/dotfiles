#!/usr/bin/env bash
# Compares a built Home Manager generation with the active one, before
# `home-manager switch`. Reads only; changes nothing.
#
#   hm-diff.sh [NEW [OLD]]
#
# NEW defaults to ./result (from `home-manager build`); OLD to the active
# home-manager profile. Written for the bash 3.2 that ships with macOS.
set -euo pipefail

new=$(readlink -f "${1:-result}")
old=${2:-}
if [[ -z $old ]]; then
  for p in "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/home-manager" \
    "/nix/var/nix/profiles/per-user/${USER:-$(id -un)}/home-manager"; do
    if [[ -e $p ]]; then
      old=$p
      break
    fi
  done
fi
[[ -n $old ]] || {
  echo "No active home-manager profile found; pass OLD." >&2
  exit 1
}
old=$(readlink -f "$old")

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export LC_ALL=C

# Store hashes differ between any two builds; hide them so diffs show content.
unhash() { sed -E 's#/nix/store/[a-z0-9]{32}-#/nix/store/…-#g'; }
section() { printf '\n=== %s\n' "$1"; }

echo "old: $old"
echo "new: $new"

section "Packages (version and size changes in the closure)"
nix --extra-experimental-features nix-command store diff-closures "$old" "$new" || true

section "Commands on PATH (- removed, + added)"
ls "$old/home-path/bin" >"$tmp/old-bin" 2>/dev/null || :
ls "$new/home-path/bin" >"$tmp/new-bin" 2>/dev/null || :
comm -23 "$tmp/old-bin" "$tmp/new-bin" | sed 's/^/- /'
comm -13 "$tmp/old-bin" "$tmp/new-bin" | sed 's/^/+ /'

section "Session variables (hm-session-vars.sh)"
vars=home-path/etc/profile.d/hm-session-vars.sh
diff -u <(unhash <"$old/$vars" 2>/dev/null) <(unhash <"$new/$vars" 2>/dev/null) || true

# Files linked into $HOME: symlinks, or files, under each home-files tree.
listfiles() { (cd "$1/home-files" && find . \( -type l -o -type f \) | sed 's#^\./##' | sort); }
listfiles "$old" >"$tmp/old-files"
listfiles "$new" >"$tmp/new-files"

section "Files in \$HOME removed (-) and added (+)"
comm -23 "$tmp/old-files" "$tmp/new-files" | sed 's/^/- ~\//'
comm -13 "$tmp/old-files" "$tmp/new-files" | sed 's/^/+ ~\//'

section "Files in \$HOME whose contents change"
comm -12 "$tmp/old-files" "$tmp/new-files" | while IFS= read -r f; do
  a="$old/home-files/$f"
  b="$new/home-files/$f"
  # The same store path is the same content; this also skips large linked
  # directories without walking them.
  [[ $(readlink -f "$a") != "$(readlink -f "$b")" ]] || continue
  if [[ -d $a || -d $b ]]; then
    diff -rq "$a" "$b" >/dev/null 2>&1 || echo "~/$f (directory)"
  elif ! cmp -s "$a" "$b" && ! cmp -s <(unhash <"$a") <(unhash <"$b"); then
    echo "--- ~/$f"
    diff -u <(unhash <"$a") <(unhash <"$b") | tail -n +3 || true
  fi
done

# Home Manager refuses to replace a file it didn't create unless the contents
# match; these would stop the switch (or be moved aside with
# `home-manager switch -b backup`). Paths with `force = true` are not known
# here, so they show up too.
section "Files the switch would refuse to overwrite"
found=
while IFS= read -r f; do
  t="$HOME/$f"
  if [[ -L $t ]]; then
    case $(readlink "$t") in /nix/store/*-home-manager-files/*) continue ;; esac
  elif [[ ! -e $t ]]; then
    continue
  fi
  cmp -s "$new/home-files/$f" "$t" && continue
  echo "~/$f"
  found=1
done <"$tmp/new-files"
[[ -n $found ]] || echo "(none)"
