# use sccache [CACHE_DIR]
#
# Compiles Rust through sccache (sccache-rustc from dotfiles), so worktrees
# share dependency builds. With CACHE_DIR, caches there, and only when its
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
  # Absolute, so cargo doesn't search PATH for it on every rustc run.
  RUSTC_WRAPPER=$(command -v sccache-rustc) || {
    log_error "sccache: sccache-rustc not on PATH"
    return 1
  }
  export RUSTC_WRAPPER
}
