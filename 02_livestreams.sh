#!/bin/bash

# https://www.reddit.com/r/Hololive/comments/neegmg/hololive_channel_ids_in_json_format/
# https://gist.github.com/emso-c/7d368b018657c84c988cae825d36cd8a
ID=(
  "UC-hM6YJuNYVAmUWxeIr9FeA"
  "UC0TXe_LYZ4scaW2XMyi5_kw"
  "UC0TXe_LYZ4scaW2XMyi5_kw"
  "UC1CfXB_kRs3C-zaeTG3oGyg"
  "UC1DCedRgGHBdm81E1llLhOQ"
  "UC1opHUrw8rvnsadT-iGp7Cg"
  "UC1suqwovbL1kzsoaZgFZLKg"
  "UC1uv2Oq6kNxgATlCiez59hw"
  "UC5CwaMl1eIgY8h02uZw7u8A"
  "UC6t3-_N8A6ME1JShZHHqOMw"
  "UC727SQYUvx5pDDGQpTICNWg"
  "UC7fk0CB07ly8oSl0aqKkqFg"
  "UC9mf_ZVpouoILRY9NUIaK-w"
  "UCa9Y57gfeY0Zro_noHRVrnw"
  "UCANDOlYTJT7N5jlRC3zfzVA"
  "UCAoy6rzhSf4ydcYjJw3WoVg"
  "UCAWSyEs_Io8MtpY3m-zqILA"
  "UCCzUftO8KOVkV4wQG1vkUvg"
  "UCD8HOxPs4Xvsm8H0ZxXGiBw"
  "UCdn5BQ06XqgXoAxIhbqw5Rg"
  "UCdn5BQ06XqgXoAxIhbqw5Rg"
  "UCDqI2jOz0weumE8s7paEk6g"
  "UCdyqAaZDKHXg4Ahi7VENThQ"
  "UCFKOVgVbGmX65RxO3EtH3iw"
  "UCFTLzh12_nrtzqBPsTCqenA"
  "UCGNI4MENvnsymYjKiZwv9eg"
  "UChAnqc_AY5_I3Px5dig3X1Q"
  "UChgTyjG-pdNvxxhdsXfHQ5Q"
  "UChSvpZYRPh0FvG4SJGSga3g"
  "UCHsx4Hqa-1ORjQTh9TYDhww"
  "UCK9V2B22uJYu3N7eR_BT9QA"
  "UCKeAhJvy8zgXWbh9duVjIaQ"
  "UCl_gCybOJRIgOXw6Qb4qJzQ"
  "UCL_qhgtOy0dy1Agp8vkySQg"
  "UCMwGHR0BTZuLsmjY_NT5Pwg"
  "UCNVEsYbiZjH5QLmGeSgTSzg"
  "UCoSrY_IQQVpmIRZ9Xf-y93g"
  "UCOyYb1c43VlX9rc_lT6NKQw"
  "UCp-5t9SrOQwXMU7iIjQfARg"
  "UCP0BspO_AMEe3aQqqpo89Dg"
  "UCp6993wxpyDPHUpavwDFqgg"
  "UCQ0UDLQCjY0rmuxCDE38FGg"
  "UCqm3BQLlJfvkTsX_hvm0UmA"
  "UCS9uQI-jC3DE0L4IpXyvr6w"
  "UCUKD-uaobj9jiqB-VXt71mA"
  "UCvaTdHTWBGv3MKj3KVqJVCw"
  "UCvInZx9h3jC2JzsIzoOebWg"
  "UCvzGlP9oQwU--Y0r9id_jnA"
  "UCwL7dgTxKo8Y4RFIKWaf8gA"
  "UCXTpFs_3PqI41qX2d9tL2Rw"
  "UCyl1z3jo3XHR1riLFKG5UAg"
  "UCYz_5n-uDuChHtLo7My1HnQ"
  "UCZgOv3YDEs-ZnZWDYVwJdmA"
  "UCZlDXzGoo7d44bwdNObFacg"
)

function poll {

  PAGE="$(/bin/timeout 10s curl -s "https://www.youtube.com/channel/$1/live")"
  R="$?"

  case "$R" in
    124|125|126|127|137)
      echo "EXIT $R"
      return "$R"
    ;;
  esac

  grep -oE '<link rel="canonical" href="https://www.youtube.com/w[^>]*>' <<<"$PAGE"

}

{

  # limit=0
  for id in "${ID[@]}"; do
    # ((limit=limit+1))
    # ((5<=limit)) && break
    poll "$id" &
  done

}
