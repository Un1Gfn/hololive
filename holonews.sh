#!/bin/bash

DEST=/home/darren/holonews

function help2 {
  echo "download"
  echo "  $(basename "$0") <yyyymmdd> <yyyymmdd> <id> News"
  echo "  $(basename "$0") <yyyymmdd> <yyyymmdd> <id> Special-<X>[-<X>...]"
  echo
  echo "comment"
  echo "  $(basename "$0") <yyyymmdd_yyyymmdd_id_XXX.pdf>"
  echo
}

function comment {
  [ 1 -eq "$#" ] || return
  read -erp "clipboard will be overwritten, ok? "; echo
  local SS='  '
  local PDF="$1"
  local I0="$IFS"
  IFS="_$IFS"
  local ID="$3"
  IFS=$I0
  # sed -e "s/@ID@/$1/g" <<EOT | xclip -i -selection clipboard
tee <<EOT | xclip -i -selection clipboard
PDF format$SS
[artifact](https://github.com/Un1Gfn/holonews/blob/master/$PDF$SS
[download link 1](https://raw.githubusercontent.com/Un1Gfn/holonews/master/$PDF$SS
[download link 2](https://github.com/Un1Gfn/holonews/raw/master/$PDF
EOT
  echo "paste clipboard below https://www.reddit.com/r/HoloNews/comments/$ID"
  echo
}

{

  echo

  case "$#" in

  1)

    comment "$1"

  ;;

  4)

    # Check args
    B="$1"  # Begin
    E="$2"  # End
    ID="$3" # Post id
    TT="$4" # Post title
    if
      [ 4 -eq "$#" ] &&
      [[ $B =~ ^2021[0-1][0-9][0-3][0-9]$ ]] &&
      [[ $E =~ ^2021[0-1][0-9][0-3][0-9]$ ]] &&
      [[ $ID =~ ^[a-z0-9]{6}$ ]] && {
        [[ $TT =~ ^Special-[A-Z][A-Za-z0-9-]+$ ]] || [ "$TT" = "News" ];
      }; then :
    else
      help2
      exit
    fi
    BASE="${B}_${E}_${ID}_${TT}"

    read -rp "all changes in worktree $DEST commited ? "
    echo

    # Check proxy
    # if type proxy_off &>/dev/null; then
    if [ 11 -eq "$(env | grep -ic "proxy")" ]; then :
    else
      printf "\e[33m%s\e[0m\n" "proxy not set"
      echo
      exit
    fi

    # Temporary directory
    D="$(mktemp -d /tmp/holonews.XXXXXXXXXX)"
    D="$D/$BASE.d"
    builtin printf "\e[32m%s\e[0m\n\n" "$D"
    { mkdir -pv "$D" && cd "$D"; } || exit

    # Grab web page and verify title
    # curl "https://www.reddit.com/r/HoloNews/comments/$ID" >index.html
    wget "https://www.reddit.com/r/HoloNews/comments/$ID" -O index.html
    # https://unix.stackexchange.com/a/278377
    T="$(sed -n -Ee 's,^.*<title>([^<]+)</title>.*$,\1,p' index.html)"
    if [ "Reddit - Dive into anything" = "$T" ]; then
      echo "please change switch to another ip"
      echo
      exit
    fi
    printf "title \e[34m%s\e[0m ok? " "$T"
    read -r
    echo

    # Extract links
    # P='<a href="https://preview.redd.it/[0-9a-z]{13}\.png\?width=1600&amp;format=png&amp;auto=webp&amp;s=[0-9a-f]{40}" .{30}'
    P='https://preview.redd.it/[0-9a-z]{13}\.png\?width=(1600|1587)&amp;format=png&amp;auto=webp&amp;s=[0-9a-f]{40}'
    LS="$(grep -E -e "$P" -o index.html)"
    # LS="$(sed -e "s|&amp;|\&|g" <<<"$LS")"
    LS="${LS//&amp;/&}"
    echo "$LS"
    echo

    # Download
    n=0
    while read -r L; do
      ((n=n+1))
      if ! wget "$L" -O "$(printf "%02d" "$n").png"; then
        echo "download error"
        echo
        exit
      fi
    done <<<"$LS"
    # if [ 10 -gt "$(wc -l <<<"$LS")" ]; then
    if [ 10 -gt "$n" ]; then
      printf "\e[33m%s\e[0m\n" "warning: less than 10 pages"
      echo
    fi

    # Write PDF
    img2pdf -- *.png >"$DEST/$BASE.pdf"
    file "$DEST/$BASE.pdf"
    echo

    # Move PNG directory
    rm -v "$D/index.html"
    cd "$DEST" || exit
    mv -vi "$D" "$DEST/$BASE.d"  || exit

    # env LC_ALL=C tree -ahFCA "$(dirname "$D")"
    ls -Alh "$BASE"*
    echo

    printf "\e[32m%s\e[0m\n" "done"
    echo

    read -rp "comment? "
    echo

    if [ -f "$DEST/$BASE.pdf" ]; then
      comment "$BASE.pdf"
    else
      printf "\e[31m%s\e[0m\n" "err"
    fi

  ;;

  *)
    help2
  ;;

  esac

}; exit
