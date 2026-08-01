#!/bin/sh

if [ "$#" -eq "0" ]; then
  cd ~/.password-store
  find . -name "?*.gpg" | sed -e 's%^\./%%' -e 's/\.gpg//g' 
  exit 0
fi

pass -c "$1" > /dev/null
