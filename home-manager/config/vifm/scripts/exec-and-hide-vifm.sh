#!/usr/bin/env zsh

swaymsg '[title="^vifm scratch$"]' scratchpad show 1>/dev/null
exec "$@"

