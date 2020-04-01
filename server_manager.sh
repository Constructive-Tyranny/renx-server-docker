#!/bin/bash

# This script is intended to be used from within the Docker container
# that manages the Renegade X server

SCRIPT_VERSION="0.1"

GAME_DATA_PATH="/mounted_volume"

GAME_PORT="7777"
IRC_PORT="7777"


HEADERTEXT="\
Renegade X headless server manager ($VERSION)
Licensed under the GNU GPLv3 free license
"

HELPTEXT="\
Usage $0 MODE [OPTIONS]
Modes of operation:
  auto                    Automatically manage and start the server
  run                     Start Renegade X server
  download                Download game data
  update                  Check for updates
  verify                  Run game data integrity check

Options:
  -p, --port              Define port to be used for game server
  -i, --irc-port          Define port to be used for IRC interface
  -h, --help              This help text
"

echo -e "$HEADERTEXT"

# Parse argumnets
SCRIPT_ARGS="$@"
if [ $# -eq 0 ]; then
  echo -e "$HELPTEXT"
  echo -e "No parameter specified."
  exit 1
else
  # Iterate through given parameters
  while [ $# -ne 0 ]; do
    case $1 in

    # Help text
    -h | --help )
      echo -e "$HELPTEXT"
      exit 1
    ;;

    # Set game port
    -p | --port )
      GAME_PORT=$2
    ;;

    # Set IRC port
    -i | --irc-port )
      IRC_PORT=$2
    ;;

    esac
    shift
  done
fi

cd "/mounted_volume/Binaries/Win64"
wine UDK.exe server CNC-Walls?maxplayers=64 -port=$GAME_PORT
