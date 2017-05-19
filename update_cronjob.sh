#!/bin/bash

FACTORIO_BIN_PATH=/opt/factorio/bin/x64
FACTORIO_UPDATER_PATH=/opt/factorio-updater

PATH=$FACTORIO_BIN_PATH:$PATH

# We have to CD into the path because the factorio update command uses relative paths
cd "$FACTORIO_BIN_PATH"

#echo got WD: `pwd`
#echo got Path: $PATH

# Get current version from Factorio server
FAC_CURRENT=`factorio --version | grep "Version" | awk '{print $2}'`
echo Checking for updates for version: $FAC_CURRENT

# Run the updater script to check and download new patches. 
# This emits the needed update command, so do some awk magic
FAC_UPDATE=`python $FACTORIO_UPDATER_PATH/update_factorio.py -x -f $FAC_CURRENT | grep "Wrote" | awk '{print $5 " " $6 "  " $7 " " $8}'`

#echo Factorio update command as returned by the script: $FAC_UPDATE

if [ -z "$FAC_UPDATE" ]; then 
   echo No updates found! Yay!; 
else
   echo Found updates. Stopping Factorio server!
   systemctl stop factorio.service

   # The emitted update commands contain backticks; we need to strip that 
   echo Extrapolating update commands
   FAC_UPDATE=${FAC_UPDATE//\`/}
   #echo got now: $FAC_UPDATE
   
   echo Executing update now!
   ${FAC_UPDATE}
   echo Update done. Return Code: $?
   echo Starting server again, please hold the line...
   systemctl start factorio.service
fi

