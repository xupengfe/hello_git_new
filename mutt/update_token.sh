#!/bin/bash


[[ -d "$HOME/mutt/contrib/" ]] || {
  echo "No $HOME/mutt/contrib/ folder!"
  exit 1
}

echo "cd $HOME/mutt/contrib/"
cd $HOME/mutt/contrib/

echo "export GPG_TTY=$(tty)"
export GPG_TTY=$(tty)

echo "$HOME/mutt/contrib/mutt_oauth2.py  local.token  --verbose --authorize"
$HOME/mutt/contrib/mutt_oauth2.py  local.token  --verbose --authorize
