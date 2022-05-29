#!/bin/bash

CACHE='/tmp/cache.mkv'

help(){
  echo "$0 URL [RES]"
  exit
}

{

  case "$#" in
    1) U="$1"; R='360p';;
    2) U="$1"; R="$2";;
    *) help;;
  esac

  # U="$1"
  # shift
  # R='360p'
  # [ -n "$1" ] && R="$1"

  STREAMLINK=(
    /bin/env https_proxy=http://127.0.0.1:8080
    /bin/streamlink -f -o "$CACHE"
    "$U" "$R"
  )

  echo

  [[ $(rm -fv "$CACHE" 2>&1 | tee /dev/stderr) ]] && echo

  touch "$CACHE"
  MPV="tail -f -c +0 '$CACHE' | mpv --pause --no-resume-playback --hwdec=vaapi --title=tv -"

  # # manually run mpv in tmux
  # echo "tmux new-session -s tv"
  # echo "$MPV"
  # echo

  # -A attach if exists
  # -d detatch
  # -c <start-directory>
  # -s <session-name>

  [[ $(tmux kill-session -t 'tv' 2>&1 | tee /dev/stderr) ]] && echo
  tmux new-session -d -c /tmp -s 'tv' /bin/bash -c "$MPV"

  [[ $(tmux kill-session -t 'streamlink' 2>&1 | tee /dev/stderr) ]] && echo
  tmux new-session    -c /tmp -s 'streamlink' "${STREAMLINK[@]}"; echo

  tmux list-session
  echo

}; exit
