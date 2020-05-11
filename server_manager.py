#!/usr/bin/python3

# This script is intended to be used from within the Docker container that
# manages the Renegade X server

#======================= Preamble =====================================

# We are now using Python so that we can have less spaghetti code


# Documentation about running Renegade X server: https://wiki.renegade-x.com/wiki/Server
# Usage of UDK.exe in command line environment: https://wiki.renegade-x.com/wiki/Command_Line
# All command line options: https://docs.unrealengine.com/udk/Three/CommandLineArguments.html

# TODO: Do we want to provide option to run 32bit binary?
# TODO: implement reading config file and loading variable values from it
# TODO: implement everything else lol

# Config file is meant to be provided in the root of mounted volume. So "/mounted_volume/config.cfg"
# Is there more fitting name for the file?

# ======================= Imports =====================================

# For interaction with the host OS
import os
import sys

# For parsing the arguments given when starting the container
import argparse

# For reading optional config file
#import configparser
# lolnope, we are using JSON instead
import json

# For starting the Renegade X server
# https://stackoverflow.com/a/4256153
# https://docs.python.org/3/library/subprocess.html
import subprocess

# For getting the information about latest Renegade X release
# https://requests.readthedocs.io/en/master/
import requests

# ======================= Metadata =====================================

script_version = 0.4
headertext="""Renegade X headless server manager
Licensed under the GNU GPLv3 free license"""

# ======================= Config ======================================

game_data_path = "/mounted_volume"
latest_release_json_url = "https://static.renegade-x.com/launcher_data/version/release.json"
automatic_update = True

# Global variables
game_port = 7777
IRC_port = 7777
max_players = 64
game_map = "CNC-Walls"
admin_password=""
mutator_list=""
to_download = False
provided_arguments = False

#======================= Functions =====================================

# Container startup logic
def main():

    # make all system normal at functioning parameters
    # olololol https://youtu.be/uXgiqBdfSz8?t=75
    parseArguments()

    # Are the game files already provided
    if checkForExpectedFiles():
        
        # TODO: figure out if it's better to verify data before checking for update
        # Check if new version of Renegade X is available
        if isGameUpToDate():
            
            # Check if game data 
            if verifyGameIntegrity():

                # TODO: figure out best way to delay execution until game is ready
                # Start mutators
                setMutators()

                # Start Renegade X server
                runGame()

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

# TODO: figure out why doing it without -silent causes wineconsole to eat up CPU
def runGame():
    
    os.chdir(game_data_path + "/Binaries/Win64/")
    
    # be careful when editing, make sure to include space bafore -
    command = "wine UDK.exe server " \
            + game_map \
            + "?maxplayers=" + str(max_players) \
            + "?mutator=" + mutator_list \
            + " -port=" + str(game_port) \
            + " -silent -lanplay -useallavailablecores"
    p = subprocess.call(command, shell=True)
    return True

# Check if user even provided any arguments
def checkForArguments():
    return False

# Override variables with values provided from command line arguments
def parseArguments():
    
    # Check if any arguments were provided at all
    if len(sys.argv) > 0:

        # create argument parser and define some arguments
        parser = argparse.ArgumentParser()
        parser.add_argument("--port", help="Port to be used on server",type=int)
        parser.add_argument("--maxplayers", help="Number of players allowed on the server",type=int)
        parser.add_argument("--map", help="Initial map to be loaded")
        args = parser.parse_args()

        global game_map
        game_map = args.map

    return True

# Override variables with values provided from config file
def readConfigFile():
    return True

def checkForExpectedFiles():
    return True

# Return false if updates are available
def isGameUpToDate():

# TODO: Keep in mind, this runs before game data is verified
# So it is possible that UDKRenegadeX.ini is corrupted. This needs to be accounted for.

# This is how it is done in BASH:
# INSTALLED_VERSION=$(cat $GAME_DATA_PATH/UDKGame/Config/UDKRenegadeX.ini | \
# grep "GameVersionNumber" | cut -d"=" -f 2 | uniq )
# LATEST_VERSION=$(curl $LATEST_RELEASE_JSON_URL | grep version_number | \
# tail -n 1 | xargs | cut -d ' ' -f 2)

    renx_ini_file_path = game_data_path + "UDKGame/Config/UDKRenegadeX.ini"

    return True

def verifyGameIntegrity():
    return True

def downloadGameData():
    return True

def availableDiskSpace():
    return True

# Populate mutator_list with names of mutators to load
def setMutators():
    return True

# Populate mutator_list with names of mutators to load
def setMap():
    return True


# ======================= Main =====================================

main()


