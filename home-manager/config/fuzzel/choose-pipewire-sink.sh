#!/bin/sh

if [ "$#" -eq "0" ]; then
  pactl list sinks | grep -E '^Sink.*|Description' | sed -z 's/\n\s*Description:/:/g' | sed 's/Sink #//g'
  exit 0
fi

eval pactl set-default-sink $(echo "$1" | cut -d":" -f1) > /dev/null 
