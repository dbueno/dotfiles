# usage:
# source <this> puts Debug euforia into path
# source <this> Release

function add_to_path {
  path="$1"
  # Checks f or the presence of the string in PATH before adding
  [ -d "$path" ] && [[ $PATH != *"$path"* ]] && PATH="$conf:$PATH"
}

conf="$HOME/work/inprogress/fmcad19/code"
add_to_path "$conf"

flavor="Debug"
if test -n "$1"; then
  flavor="$1"
fi
euforia_path="$HOME/work/inprogress/euforia/vmt4/code/euforia/build/$flavor/bin"
add_to_path "$euforia_path"
