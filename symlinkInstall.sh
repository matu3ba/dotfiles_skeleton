#!/bin/bash
## search sub-folder paths and create symlinks of un-ignored files
## example: ln -s $HOME/dotfiles/.bashrc $HOME/.bashrc

# The following script assumes filenames do not contain
# control characters and dont contain leading dashes(-).
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes
IFS="`printf '\n\t'`" # change IFS to just newline and tab

FAIL="FALSE"            # will be filled with defaults
cd "${HOME}/dotfiles"
dotfilePaths="$(fd -uu --type f --ignore-file "${HOME}/dotfiles/ignorefiles")"

while IFS= read -r dfPath; do
  printf '%-40s' "${dfPath}"
  #echo "${dfPath}"
  dfabsPath="${HOME}/dotfiles/${dfPath}"
  canonpath=$(realpath "${dfabsPath}")
  symlinkAbsPath="${HOME}/${dfPath}"
  fileName="${dfPath%/*}"
  sysFolderPath=$(dirname "${symlinkAbsPath}")
  #echo "${sysFolderPath}"
  mkdir -p "${sysFolderPath}"
  printf '%-20s' "folder ensured"
  if test -e "${symlinkAbsPath}"; then
    if ! test -L "${symlinkAbsPath}"; then
      FAIL="TRUE"
      printf '%-20s' "user profile: found file other than symlink"
    else
      linkTarget=$(readlink -e "${symlinkAbsPath}")
      #echo "linkTarget: ${linkTarget}"
      if test "${linkTarget}" != "${canonpath}"; then
        FAIL="TRUE"
        printf '%-20s' "symlink broken"
      else
        printf '%-20s' "symlink OK"
      fi
    fi
  else
    ln -s "${canonpath}" "${symlinkAbsPath}"
    printf '%-20s' "user profile: created symlink"
  fi
  echo -en "\n"
done <<< "${dotfilePaths}"
echo "failure occured: ${FAIL}"
