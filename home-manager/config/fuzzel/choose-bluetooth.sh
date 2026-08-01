#!/bin/sh

if [ "$#" -eq "0" ]; then
  connected=$(echo "devices Connected" | bluetoothctl | grep '^Device.*' | cut -d" " -f2-)
  paired=$(echo "devices Paired" | bluetoothctl | grep '^Device.*' | cut -d" " -f2-)

  echo "${connected}" | while read device; do
    if [ -n "${device}" ]; then
      echo disconnect "${device}"
    fi
  done

  echo "${paired}" | while read device; do
    if [ -n "${device}" ]; then
      echo connect "${device}"
    fi
  done
  exit 0
fi

echo "$@" | cut -d" " -f1-2 | bluetoothctl > /dev/null &
