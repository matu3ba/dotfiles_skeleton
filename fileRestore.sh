#!/bin/bash
## delete regular files only depending on structure of dotfiles
## example: if $1 is a path leading to $HOME/back/FOLDER, we restore
## restoring only works, if there is currently no file

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes
FAIL="TRUE"            # will be filled with defaults

cd "${HOME}/dotfiles"
dotfilePaths="$(fd -uu --type f --ignore-file "${HOME}/dotfiles/ignorefiles")"

if test -z "$1"; then
  echo "no path to restore folder"
  echo "usage: ./fileRestore.sh $HOME/back/FOLDER"
fi

ROOT_BACK_FOLDER="$1"
rootbackupFolderPath=$(dirname "$ROOT_BACK_FOLDER")
if test "$rootbackupFolderPath" != "${HOME}/back"; then
  echo '$1 (backup folder) is not in $HOME/back'
  echo "usage: ./fileRestore.sh $HOME/back/FOLDER"
fi
if ! test -d "$rootbackupFolderPath"; then
  echo '$1 (backup folder) is no folder'
  echo "usage: ./fileRestore.sh $HOME/back/FOLDER"
fi

while IFS= read -r dfPath; do
  printf '%-40s' "$dfPath"
  dfabsPath="${HOME}/dotfiles/${dfPath}"
  backupAbsPath="${ROOT_BACK_FOLDER}/${dfPath}"
  backupFolderPath=$(dirname "$backupAbsPath")
  sysAbsPath="${HOME}/${dfPath}"
  sysFolderPath=$(dirname "$sysAbsPath")
  if test -e "$dfabsPath"; then
    if test -f "$backupAbsPath"; then
      if ! test -e "$sysAbsPath"; then
        cp "$backupAbsPath" "$sysAbsPath"
        printf '%-20s' "did restore"
        FAIL="FALSE"
      else
        printf '%-20s' "file in user profile"
      fi
    else
      printf '%-20s' "backup: no such regular file"
    fi
  else
    printf '%-20s' "FATAL: fix fd or ignorefiles"
  fi
  echo -en "\n"
done <<< "$dotfilePaths"
if test "$FAIL" = "FALSE"; then
  echo "restored from ${ROOT_BACK_FOLDER}"
else
  echo "could not restore from ${ROOT_BACK_FOLDER}"
fi
