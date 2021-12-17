#!/bin/bash
## check if this script is in $HOME/dotfiles for correct system configuration as per XDGBDS
## search sub-folder paths and test symlinks of un-ignored files
## requires fd (Rust program), because find does not support an ignore list
## POSIX shell, because nobody wrote a common subscript detection

# The following script assumes filenames do not contain
# control characters and dont contain leading dashes(-).
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes
IFS="`printf '\n\t'`" # change IFS to just newline and tab

FAIL="FALSE"
dotfilePaths=""

cd "${HOME}/dotfiles"
symlinksExist=""
symlinksExist="$(fd -uu --type l --ignore-file "${HOME}/dotfiles/ignorefiles")"
if test "$symlinksExist" != ""; then
  echo "incorrect content inside dotfiles"
  exit 1
fi

dotfilePaths="$(fd -uu --type f --ignore-file "${HOME}/dotfiles/ignorefiles")"
#this does separate with newline blocks!
if test "${dotfilePaths}" == ""; then
  echo "no paths"
  exit 2
else
  while IFS= read -r dfPath; do
    printf '%-40s' "$dfPath"
    #echo "$dfPath"
    dfabsPath="${HOME}/dotfiles/${dfPath}"
    canonpath=$(realpath "${dfabsPath}")
    symlinkAbsPath="${HOME}/${dfPath}"
    if test -e "$symlinkAbsPath"; then
      if ! test -L "$symlinkAbsPath"; then
        FAIL="TRUE"
        printf '%-20s' "user profile: found file other than symlink"
        #exit 3
      else
        linkTarget=$(readlink -e "$symlinkAbsPath")
        #echo "linkTarget: ${linkTarget}"
        #echo "dfabsPath: ${dfabsPath}"
        #echo "canonpath: ${canonpath}"
        if test "$linkTarget" != "$canonpath"; then
          printf '%-20s' "symlink broken"
        else
          printf '%-20s' "symlink OK"
        fi
      fi
    else
      printf '%-20s' "user profile: found no file"
    fi
    echo -en "\n"
  done <<< "$dotfilePaths"
  echo "failure occured: $FAIL"
fi
