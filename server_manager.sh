#!/bin/bash

# This script is intended to be used from within the Docker container
# that manages the Renegade X server

#======================= Preamble =====================================
#
# I just remembered that BASH scripting is bascally duct-taping
# various workarounds together until code does approximately what you
# would want it to do. TODO: Switch to Python as soon as possible.
#
# I was about to split this into two parts:
# One script that would be made specifically to run in Docker and one
# more general script that would serve as a headless server that could
# be used in more Linux environments than just Docker.
# The first script would then just orchestrate the second script.
# But turns out that doing so would be very impractical because
# the output of the first script would need to have various funky
# methods of getting the output / results of the actions done in second
# script. So for now everything goes into one script.
# And this script stays Docker-specific. Which means help text goes away
# and overall modularity gets decreased. Script is not meant to be user
# firendly in the current state.

# TODO: implement reading config file and loading variable values from it
# TODO: implement everything else lol


#======================= Config =======================================

SCRIPT_VERSION="0.1"

GAME_DATA_PATH="/mounted_volume"
LATEST_RELEASE_JSON_URL="https://static.renegade-x.com/launcher_data/version/release.json"

AUTOMATIC_UPDATE=true

DEFAULT_GAME_PORT="7777"
DEFAULT_IRC_PORT="7777"
DEFAULT_MAX_PLAYERS="64"
DEFAULT_GAME_MAP="CNC-Walls"


HEADERTEXT="\
Renegade X headless server manager ($SCRIPT_VERSION)
Licensed under the GNU GPLv3 free license
"

#======================= Functions =====================================

# Compares version numbers from installed game and the latest release
function check_for_updates() {

    # uniq because we assume that resulting lines will have the same value
    # could use "head -n 1" in order to take just the first line
    INSTALLED_VERSION=$(cat $GAME_DATA_PATH/UDKGame/Config/UDKRenegadeX.ini | \
    grep "GameVersionNumber" | cut -d"=" -f 2 | uniq )
    LATEST_VERSION=$(curl $LATEST_RELEASE_JSON_URL | grep version_number | \
    tail -n 1 | xargs | cut -d ' ' -f 2)

    [ $INSTALLED_VERSION = $LATEST_VERSION ] && echo "yep"

}


#======================= Main ==========================================

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

# Check if the expected files are present
# TODO: check for *specific* files instead of *any* files
if [ "$(ls -A $GAME_DATA_PATH)" ]; then
    if [ $AUTOMATIC_UPDATE ]; then
        if [ $(check_for_updates) ]; then
            
        fi
    fi
else
    DOWNLOAD_GAME=true
fi

# use https://static.renegade-x.com/launcher_data/version/release.json to get version

# Verify game integrity
if [ $VERIFY_DATA ]; then
    # TODO: use the most lightweight method of verfiying files
    RUN_GAME=true
fi

# Download whole game
if [ $DOWNLOAD_GAME ]; then
    AVAILABLE_SPACE=$(df -Pk . | tail -1 | awk '{print $4}')
    REQUIRED_SPACE=9001
    if 
fi

# Verify game integrity
if [ $RUN_GAME ]; then
    cd $GAME_DATA_PATH"/Binaries/Win64"
    wine UDK.exe server $GAME_MAP?maxplayers=$MAX_PLAYERS -port=$GAME_PORT
fi
