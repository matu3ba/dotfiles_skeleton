#!/bin/bash
## search sub-folder paths and create symlinks of un-ignored files
## example: ln -s $HOME/dotfiles/.bashrc $HOME/.bashrc

# The following script assumes filenames do not contain
# control characters and dont contain leading dashes(-).
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes
IFS="`printf '\n\t'`" # change IFS to just newline and tab

FAIL="TRUE"
cd "${HOME}/dotfiles"
dotfilePaths="$(fd -uu --type f --ignore-file "${HOME}/dotfiles/ignorefiles")"

DATETIME=`date +"%Y%m%d_%H%M%S"`
BACK_FOLDER="${HOME}/back/${DATETIME}_backconfig/"
#mkdir -p "$BACK_FOLDER"

while IFS= read -r dfPath; do
  printf '%-40s' "$dfPath"
  #dfabsPath="${HOME}/dotfiles/${dfPath}"
  backupAbsPath="${BACK_FOLDER}/${dfPath}"
  backupFolderPath=$(dirname "$backupAbsPath")
  sysAbsPath="${HOME}/${dfPath}"
  if test -e "$sysAbsPath"; then
    if ! test -L "$sysAbsPath"; then
      if test -f "$sysAbsPath"; then #regular file?
        mkdir -p "$backupFolderPath"
        cp "$sysAbsPath" "$backupAbsPath"
        printf '%-20s' "did backup"
        FAIL="FALSE"
      else
        printf '%-20s' "no symlink or regular file"
      fi
    else
      printf '%-20s' "is symlink"
    fi
  else
    printf '%-20s' "found no file"
  fi
  echo -en "\n"
done <<< "$dotfilePaths"
if test "$FAIL" = "FALSE"; then
  echo "backup created at ${BACK_FOLDER}"
fi
