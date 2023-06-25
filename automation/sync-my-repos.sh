#!/usr/bin/env bash

# Repos are configure in ~/.config/automate-everything/repos, one per line.
# Tilde-expansion is performed.


mode="none"
num_jobs="8"
verbose=""
while getopts ":vj:h" opt; do
    case $opt in
        j)
            num_jobs="$OPTARG"
            ;;

        v)
            verbose="1"
            ;;

        h)
            echo "$0 [options] [push|pull]"
            echo "    -h help"
            echo "    -j N run N parallel jobs"
            exit 0
            ;;
    esac
done
shift $((OPTIND -1))
while [[ $# -gt 0 ]]; do
  opt=$1
  shift
  case $opt in
      pull)
          mode="pull"
          ;;

      push)
          mode="push"
          ;;

      *)
          printf "error: unknown command: %s\n" $opt
          exit 1
          ;;
  esac
done

check_git_untracked_files() {
    num_untracked=$(git status --porcelain 2>/dev/null | grep "^??" | wc -l)
    if [[ $((num_untracked)) > 0 ]]; then
        printf "$(pwd): %d untracked files\n" $num_untracked
        ret=1
        return 1
    fi
}
export -f check_git_untracked_files

check_git_clean() {
    if ! git diff-index --quiet "$@" HEAD; then
        printf "$(pwd): uncommitted changes\n"
        ret=1
        return 1
    fi
}
export -f check_git_clean

check_git_uptodate() {
    branch=$(git branch | cut -d' ' -f2)
    # Garbage from stackoverflow
    tracking_branch=$(git for-each-ref --format="%(upstream:short)" "$(git symbolic-ref -q HEAD)")
    num_commits_ahead=$(git rev-list --count $tracking_branch..$branch)
    if [[ $num_commits_ahead > 0 ]]; then
        printf "$(pwd): branch %s has %d more commits than tracking branch %s\n" $branch $num_commits_ahead $tracking_branch
        ret=1
        return 1
    fi
}
export -f check_git_uptodate


# Set by the git functions above if there's a failure
ret=0
export ret mode verbose

examine_repo() {
    repo="$1"
    if test -n "$verbose"; then
        echo ">>> $repo"
    fi
    cd $repo
    if [ $mode = "pull" ]; then
      git pull || exit 1
    fi
    if [ $mode = "push" ]; then
      git push || exit 1
    fi
    check_git_clean --ignore-submodules
    check_git_untracked_files
    check_git_uptodate
}
export -f examine_repo

repos_tmp=`mktemp automate-everythingXXXXXX.txt`
trap cleanup EXIT
cleanup() {
    env rm "$repos_tmp"
}

# Reads repos and expands ~
cat ~/.config/automate-everything/repos | \
    while read repo; do
        # Expand ~ in path
        repo="${repo/#\~/$HOME}"
        if test ! -d "$repo"; then
            continue;
        fi
        echo "$repo" >> "$repos_tmp"
    done

cat "$repos_tmp" | \
    parallel -j$num_jobs examine_repo

exit $ret
