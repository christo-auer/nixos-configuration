#!/bin/sh

fuzzel=$1
chooser=$2

action=$(${chooser} | ${fuzzel} --dmenu)

if [ -n "${action}" ]; then
  ${chooser} "${action}"
fi
