#!/bin/bash
## search sub-folder paths and remove symlinks of un-ignored files
## example: if .bashrc is symlink -> rm $HOME/.bashrc

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes
FAIL="FALSE"            # will be filled with defaults

cd "${HOME}/dotfiles"

# can not retrieve values from subscript
dotfilePaths="$(fd -uu --type f --ignore-file "${HOME}/dotfiles/ignorefiles")"

while IFS= read -r dfPath; do
  printf '%-40s' "$dfPath"
  #echo "$dfPath"
  dfabsPath="${HOME}/dotfiles/${dfPath}"
  symlinkAbsPath="${HOME}/${dfPath}"
  if test -e "$symlinkAbsPath"; then
    if ! test -L "$symlinkAbsPath"; then
      FAIL="TRUE"
      printf '%-20s' "user profile: found file other than symlink"
    else
      linkTarget=$(readlink -e "$symlinkAbsPath")
      #echo "linkTarget: ${linkTarget}"
      if test "$linkTarget" != "$dfabsPath"; then
        FAIL="TRUE"
        printf '%-20s' "symlink broken"
      else
        rm "$symlinkAbsPath"
        printf '%-20s' "removed valid symlink"
      fi
    fi
  else
    printf '%-20s' "user profile: found no symlink"
  fi
  echo -en "\n"
done <<< "$dotfilePaths"
echo "failure occured: $FAIL"
