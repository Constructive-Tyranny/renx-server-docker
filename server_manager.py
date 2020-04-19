#!/usr/bin/python3

# This script is intended to be used from within the Docker container
# that manages the Renegade X server

#======================= Preamble =====================================

# We are now using Python so that we can have less spaghetti code



# TODO: Do we want to provide option to run 32bit binary?
# TODO: implement reading config file and loading variable values from it
# TODO: implement everything else lol

# ======================= Imports =====================================

# https://stackoverflow.com/a/4256153
# https://docs.python.org/3/library/subprocess.html
import subprocess
#https://requests.readthedocs.io/en/master/
import requests
import argparse 	
import os


# ======================= Metadata =====================================
script_version = 0.2
headertext="""Renegade X headless server manager
Licensed under the GNU GPLv3 free license"""

# ======================= Config ======================================

game_data_path = "/mounted_volume"
latest_release_json_url = "https://static.renegade-x.com/launcher_data/version/release.json"
automatic_update = True
default_game_port = 7777
default_IRC_port = 7777
default_max_players = 64
default_game_map = "CNC-Walls"


# define some variables
game_port = default_game_port
IRC_port = default_IRC_port
max_players = default_max_players
game_map = default_game_map
to_download = False


#======================= Functions =====================================

def parseArguments():
    game_port = default_game_port
    IRC_port = default_IRC_port
    max_players = default_max_players
    game_map = default_game_map
    return True

def checkForExpectedFiles():
    return True

# return false if updates are available
def isUpToDate():

# TODO: Keep in mind, this runs before game data is verified
# So it is possible that UDKRenegadeX.ini is corrupted. This needs to be accounted for.

# This is how it is done in BASH:
#    INSTALLED_VERSION=$(cat $GAME_DATA_PATH/UDKGame/Config/UDKRenegadeX.ini | \
#    grep "GameVersionNumber" | cut -d"=" -f 2 | uniq )
#    LATEST_VERSION=$(curl $LATEST_RELEASE_JSON_URL | grep version_number | \
#    tail -n 1 | xargs | cut -d ' ' -f 2)
    renx_ini_file_path = game_data_path + "UDKGame/Config/UDKRenegadeX.ini"


    return True

def verifyGameIntegrity():
    return True

def downloadGameData():
    return True

def availableDiskSpace():
    return True

def runMutators():
    return True

def runGame():
     	
    os.chdir(game_data_path + "/Binaries/Win64/")
    command = "wine UDK.exe server " + str(game_map) + "?maxplayers=" + str(max_players) + "-port=" + str(game_port)
    p = subprocess.call(command, shell=True)
    return True



#======================= Main =====================================

# make all system normal at functioning parameters
# olololol https://youtu.be/uXgiqBdfSz8?t=75
parseArguments()

# Are the game files already provided
if checkForExpectedFiles() :
    
    # TODO: figure out if it's better to verify data before checking for update
    # Check if new version of Renegade X is available
    if isUpToDate():
        
        # Check if game data 
        if verifyGameIntegrity():

            # Start Renegade X server
            runGame()
            
            # TODO: figure out best way to delay execution until game is ready
            # Start mutators
            runMutators()

        # Game data is present but does not pass validity check
        else:

            # Mark game to be re-downloaded
            to_download = "game"

    # Mark game to be patched with new update
    else:
        to_download = "patch"

# No game data is present
else:
    
    # Mark whole game to be downloaded
    to_download = "game"


