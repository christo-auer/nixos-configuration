#!/usr/bin/env bash

set -e

debug=0
if [[ "$1" == "--debug" ]]
then
    debug=1
    shift 1
fi

[[ "$debug" == "1" ]] && echo "Called with $@" >&2

if [ "$#" -ne 3 ]
then
    echo "Usage: $0 [--debug] <path_to_image> <width> <height>"
    exit 1
fi

# number of pixels for which to render the image
width=$(($2*8*3))
height=$(($3*14*3))

mime_type="$(file --mime-type --brief -- $1)"

case "$mime_type" in

    image/jpeg|image/png)
        [[ "$debug" == "1" ]] && echo "File type: image/{jpeg,png}" >&2
        exec magick -- "$1" -auto-orient -strip -scale "${width}x${height}>" - | img2sixel
        ;;

    image/gif)
        [[ "$debug" == "1" ]] && echo "File type: image/gif" >&2
        exec magick -- "$1[0]" -auto-orient -strip -scale "${width}x${height}>" JPEG:- | img2sixel
        ;;

    *)
        [[ "$debug" == "1" ]] && echo "Unknown file type: $mime_type, attempting conversion" >&2
        exec magick -- "$1" -auto-orient -strip -scale "${width}x${height}>" JPEG:- | img2sixel
        ;;
esac
