 #! /usr/bin/env bash
#
# Name: bash_rsync.sh
#
# Brief: Bash script that uses rsync to backup files from a specific directory  
# on computer to external hard drive, USB drive, etc. 
# - Script includes user prompts, since including or excluding a trailing / 
# is tricky, when entering the source & destination/target.
# - Prevents: Creation of unwanted duplicated sub-directories.
#
# Author: Kim Lew

# For SOURCE: 
# State the specific sub-directory WITHOUT /.
# For DESTINATION (target): 
# Do NOT state specific sub-directory, BUT add a /.

# Note: rsync is smart enough to create the sub-directory, if it doesn't already
# exist, & transfers contents. 
# If sub-directory already exists, rsync just transfers contents.

# Limitation: Only 2 USB ports on laptop.

while true
do
  clear
  cat <<MENU
  BACKUP from laptop to a storage device
  --------------------------------------
  1. Documents folder contents on laptop -> Red Toshiba, then Documents contents on laptop -> Blue Toshiba
  2. PHOTOS folder contents on laptop -> Red Toshiba, then PHOTOS contents on laptop -> Blue Toshiba
  3. Photos folder contents on Kingston USB -> Red Toshiba
  4. Photos folder contents on Kingston USB -> Blue Toshiba
  0. Quit
  ------------------------------------
MENU
# Custom user prompt. 
PS3="Which backup are you doing? Type 1 to 4, or 0 to quit: "
:'
echo "Type SOURCE directory path, WITH specific sub-directory & LEAVE OFF trailing /."
echo "(Example: /Users/kimlew/Documents):"
read source_path
echo "Type DESTINATION directory path, WITHOUT sub-directory & ADD a trailing /."
echo "(Example: /Volumes/KINGSTON/):"
read destination_path

echo "Source you typed is: $source_path"
echo "Destination you typed is: $destination_path"
'
read -r -p 

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
rsync -av --exclude={'.Spotlight-V100','.Trashes','.fseventsd'} "$source_path" \
"$destination_path" && echo "Sync is done."

done
