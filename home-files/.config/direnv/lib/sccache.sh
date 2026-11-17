# use sccache [CACHE_DIR]
#
# Compiles Rust through sccache (sccache-rustc from dotfiles), so worktrees
# share builds. With CACHE_DIR, caches there, and only when its
# parent exists, so a missing external disk turns caching off instead of
# filling the default cache location.
use_sccache() {
  local dir=${1:-}
  if [[ -n $dir ]]; then
    if [[ ! -d ${dir%/*} ]]; then
      log_status "sccache: ${dir%/*} is missing; not caching"
      return 0
    fi
    export SCCACHE_DIR=$dir
  fi
  export SCCACHE_CACHE_SIZE=${SCCACHE_CACHE_SIZE:-100G}
  # Strip this checkout and its target dir from cache keys, so crates whose
  # keys include them (OUT_DIR from build scripts, workspace sources) hit
  # entries another worktree wrote. The server reads SCCACHE_BASEDIRS only at
  # startup, so each project gets its own server, on a port derived from its
  # path; all of them share SCCACHE_DIR. Set CARGO_TARGET_DIR before this.
  local target=${CARGO_TARGET_DIR:-$PWD/target}
  [[ $target == /* ]] || target=$PWD/$target
  export SCCACHE_BASEDIRS="$PWD:$target"
  # A crate that bakes in its checkout's path must not get another checkout's.
  export SCCACHE_BASEDIRS_VERBATIM_ENV_DEPS=CARGO_MANIFEST_DIR,CARGO_MANIFEST_PATH
  local sum
  sum=$(printf %s "$PWD" | cksum)
  export SCCACHE_SERVER_PORT=$((10000 + ${sum%% *} % 50000))
  # Absolute, so cargo doesn't search PATH for it on every rustc run.
  RUSTC_WRAPPER=$(command -v sccache-rustc) || {
    log_error "sccache: sccache-rustc not on PATH"
    return 1
  }
  export RUSTC_WRAPPER
}
