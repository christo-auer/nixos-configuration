#!/bin/sh

account="$1"

if [ -n "$2" ]; then
  subfolder="-$2"
else
  subfolder=""
fi

mbsync_group="${account}${subfolder}"

mbsync --quiet --quiet "${mbsync_group}"
notmuch new 1>/dev/null
~/.config/notmuch/default/hooks/post-new
