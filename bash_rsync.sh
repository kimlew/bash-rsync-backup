 #! /usr/bin/env bash
#
# Name: bash_rsync.sh
#
# Brief: Bash script that uses rsync to backup files & folders from computer 
# to external hard drive, USB drive, etc. 
# - Script includes user prompts, since including or excluding a trailing / 
# is tricky when entering the source and destination/target.
# - Prevents user from ending up with extra unwanted sub-directories.
#
# Author: Kim Lew

# Display user prompts of what to enter to prevent creating extra sub-directories.
# For the source: 
# Enter the specific sub-directory WITHOUT /. rsync is smart enough to
# create the sub-directory if it doesn't exist & transfers contents. 
# If sub-directory already exists, rsync transfers contents. 
# For the destination/target: 
# You do NOT need to state specific sub-directory BUT you do need /.
echo "Type source directory path WITH specific sub-directory & LEAVE OFF trailing /."
echo "(Example: /Users/kimlew/Documents):"
read source_path
echo "Type destination directory path WITHOUT sub-directory & ADD a trailing /."
echo "(Example: /Volumes/KINGSTON/):"
read destination_path

echo "Source you typed is: $source_path"
echo "Destination you typed is: $destination_path"

# Check for valid directory paths for source & destination.
if [ ! -d "$source_path" ]
then
    echo "This source directory does NOT exist."
    exit 1
fi
if [ ! -d "$destination_path" ]
then
    echo "This destination directory does NOT exist."
    exit 1
fi

# -a, --archive - archive mode; same as -rlptgoD (no -H). -a implies -r.
# -v is verbose vs. -q, --quiet - to suppress non-error messages.

echo "File sync in progress..."
echo "..."
rsync -av "$source_path" "$destination_path" && echo "Sync is done."
