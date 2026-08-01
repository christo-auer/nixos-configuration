#!/bin/sh

if [ "$#" -eq "0" ]; then
  active=$(nmcli connection show --active | tail -n+2 | sed 's/\s*[0-9a-f]\{8\}.*//g')
  active_count=$(echo "${active}" | wc -l)
  active_line=$(expr "${active_count}" + 1)
  inactive=$(nmcli connection show | tail -n+2 | tail -n+${active_line} | sed 's/\s*[0-9a-f]\{8\}.*//g')

  echo "${active}" | while read conn; do
    echo down \"${conn}\"
  done
  echo "${inactive}" | while read conn; do
    echo up \"${conn}\"
  done
  exit 0
fi

eval nmcli connection "$@" 
