#!/bin/bash

# /usr/local/bin/mpv.sh

# TODO
# openvt https://superuser.com/a/819299/

export DISPLAY=:0.0
export XAUTHORITY=/home/darren/.Xauthority
export XDG_RUNTIME_DIR=/run/user/1000

# https://wiki.archlinux.org/title/Youtube-dl#Faster_downloads
EXT="external-downloader=aria2c,external-downloader-args=-j3 -c -x3 -k1M -s3"
ID=""
AO=false
DEBUG=false

MPV=(
  # --window-scale=
  # --window-maximized=
  --fs
  --pause
  --cache=yes
  --cache-secs=90
  --demuxer-readahead-secs=180
  --demuxer-max-back-bytes=1G
  --demuxer-max-bytes=1G
  --keep-open=yes
  # mpv(1) - Keyboard Control - Q - store the current playback position
  --no-resume-playback
)

function to_external_monitor {
  MPV+=(--title=tv_820g3.sh)
  N="$(xrandr -q | grep -v disconnected | grep -c connected)"
  if [ 2 -eq "$N" ]; then
    MPV+=(--screen=1)
    MPV+=(--fs-screen=1)
  else
    [ 1 -eq "$N" ] || exit 1
  fi
}

function is_x200 {
  # get id with "lspci -nn"
  # 00:02.0 VGA compatible controller: Intel Corporation Mobile 4 Series Chipset Integrated Graphics Controller (rev 07)
  [ 1 -eq "$(lspci -d '8086:2a42' | wc -l)" ] \
    && [ "x200" = "$(< /proc/sys/kernel/hostname)" ] \
    && [ "x200" = "$HOSTNAME" ] \
    && [ "x200" = "$(busybox hostname)" ]
}

function is_820g3 {
  # get id with "lspci -nn"
  # 00:02.0 VGA compatible controller: Intel Corporation Skylake GT2 [HD Graphics 520] (rev 07)
  [ 1 -eq "$(lspci -d '8086:1916' | wc -l)" ] \
    && [ "820g3" = "$(< /proc/sys/kernel/hostname)" ] \
    && [ "820g3" = "$HOSTNAME" ] \
    && [ "820g3" = "$(busybox hostname)" ]
}

function capfps {
  is_x200 && MPV+=(--vf-add=fps=30:round=near) && return
  is_820g3 && return
  echo "unknown device"
  exit 1
}

function proxy_and_title {
  source /home/darren/proxy.bashrc 1>/dev/null
  alacrittytitle.sh "tv.sh"
}

function play_file {
  if "$DEBUG"; then
    echo "("
    for i in "${MPV[@]}"; do
      echo "  $i"
    done
    echo ")"
  fi
  free -h
  # shellcheck disable=SC1091
  proxy_and_title
  exec mpv "${MPV[@]}" "$ID"
  echo "${FUNCNAME[0]}() unreachable"
  exit 1
}

function play_stream {
  "$DEBUG" && echo "${MPV[*]}"
  # exit 1
  free -h
  exec streamlink \
    --http-proxy "socks5h://127.0.0.1:1080" \
    -p "mpv" \
    -a "${MPV[*]}" \
    -v \
    --stream-segment-threads 2 \
    --ringbuffer-size 64M \
    "https://www.youtube.com/watch?v=$ID" \
    "$1"
  echo "${FUNCNAME[0]}() unreachable"
  exit 1
}

function play_archive {
  if "$DEBUG"; then
    echo "("
    for i in "${MPV[@]}"; do
      echo "  $i"
    done
    echo ")"
  fi
  # exit 1
  # shellcheck disable=SC1091
  free -h
  # shellcheck disable=SC1091
  proxy_and_title
  exec mpv "${MPV[@]}" "ytdl://$ID"
  echo "${FUNCNAME[0]}() unreachable"
  exit 1
}

function help {
  echo "$(basename "$0") [-adh] URL"
}

{

  # is_x200 || [ -v NOSCP ] || {
  #   # to bootstrap, run the following 1 line only
  #   # -o ConnectTimeout=3
  #   # scp root@x200:/usr/local/bin/tv.sh /home/darren/.local/bin/tv.slave.sh
  #   export NOSCP=1
  #   exec /bin/bash /home/darren/.local/bin/tv.slave.sh "$@"
  # }

  alacrittytitle.sh "tv.sh"

  xset dpms force on

  while getopts 'adh' name; do case "$name" in
    a)
      echo audio_only
      AO=true
      ;;
    d)
      DEBUG=true
      ;;
    # Excessive/Superfluous
    # h)
    #   help
    #   exit 1
    #   ;;
    *)
      help
      exit 1
      ;;
  esac;  done
  shift "$((OPTIND-1))"

  [ "$(whoami)" = darren ] || {
    echo "unprivileged user required"
    exit 1
  }

  # parse args
  case "$1" in
    *yandex*|*ipfs.io*)
        capfps
        ID="$1"
        play_file
        ;;
  esac
  case "${1^^?}" in
    "ANN")  set -- 'https://www.youtube.com/watch?v=coYw-eVU0Ks' ;;
    "NBC")  set -- 'https://www.youtube.com/watch?v=YoRHn4Rw4Vk' ;;
    "TVBS") set -- 'https://www.youtube.com/watch?v=2mCSYvcfhtc' ;;
  esac
  if ((1==$#)) && {
    [[ "$1" =~ ^(https://(www.youtube.com/watch\?v=|youtu.be/)([A-Za-z0-9_-]{11})).*t=([0-9]+) ]] ||
    [[ "$1" =~ ^(https://(www.youtube.com/watch\?v=|youtu.be/)([A-Za-z0-9_-]{11})) ]];
  }; then
    ID="${BASH_REMATCH[3]}"
    START="${BASH_REMATCH[4]}"
    [[ "$ID" =~ ^[A-Za-z0-9_-]{11}$ ]] || exit 1
    echo "[3] $ID"
    if [ 1 -le "$START" ] 2>/dev/null; then
      echo "[4] $START"
      MPV+=(--start="$START")
    fi
  else
    help
    exit 1
  fi

  # wait
  while true; do
    X="$(yt-dlp --proxy socks5://127.0.0.1:1080 -q -F "https://www.youtube.com/watch?v=$ID" 2>&1)"
    # ERROR: [youtube] r2kN4QFXqWo: This live event will begin in a few moments.
    if [[ "$X" =~ This\ live\ event\ will\ begin\ in\ (.*)\.$ ]]; then
      echo "${BASH_REMATCH[0]}"
      echo "${BASH_REMATCH[1]}"
      # date -ud'19700101 10 minutes' +%s
      # T=max(T/2,15)
      T=15
      printf "sleeping %s seconds..." "$T"
      sleep "$T"
      echo
      xset dpms force on
    else
      break
    fi
  done

  # audio only
  "$AO" && {
    grep -e '^140 .*mp4a\.40\.2 ' <<<"$X" && {
      MPV+=(--vid=no)
      MPV+=(--ytdl-format=140)
      play_archive
    }
    echo "audio not found"
    exit 1
  }

  # here we go

  # whether we use hardware acceleration
  is_820g3 && MPV+=(--vo=gpu --hwdec=vaapi)

  to_external_monitor

  # 1080p30
  grep -Ee '^96.* avc1.(640028|4d4028) ' <<<"$X" && play_stream 1080p

  # 1080p60->1080p30 (non-rewindable)
  grep -e '^301 .*avc1\.4d402a '         <<<"$X" && capfps && play_stream 1080p

  # 1080p60->1080p30 (rewindable/premiere)
  grep -e '^301 .*avc1\.64002a '         <<<"$X" && capfps && play_stream 1080p

  # 720p30
  grep -e  '^95 .*avc1\.4d401f '         <<<"$X" && play_stream 720p

  grep -e '^140 .*mp4a\.40\.2 '          <<<"$X" && {
    MPV+=(--ytdl-raw-options="$EXT")
    grep -e '^137.*avc1\.640028 ' <<<"$X" && MPV+=(--ytdl-format="140+137") && play_archive
    grep -e '^303 .*vp9 ' <<<"$X" && {
      MPV+=(--ytdl-format="140+303")
      MPV+=(--hwdec=no) # [ffmpeg/video] vp9: No support for codec vp9 profile 0.
      capfps
      play_archive
    }
    grep -e '^247 .*vp9 ' <<<"$X" && {
      printf "\033[33m%s\033[0m\n" "warning - this archive is 720p only"
      MPV+=(--ytdl-format="140+247")
      play_archive
    }
    echo "invalid archive vcodec "
    exit 1
  }

  echo "unknown type"
  "$DEBUG" && echo "$X"
  exit 1

}; exit
