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

# Check for valid directory paths for source & destination.
check_source() {
    if [ ! -d "$source_path" ]
    then
        echo "This source directory does NOT exist."
        exit 1
    fi
    
}
check_destination() {
    if [ ! -d "$destination_path" ]
    then
        echo "This destination directory does NOT exist."
        exit 1
    fi
}

while true
do
    clear

    cat <<MENU
    BACKUP Contents from a Directory on Laptop to a Storage Device
    --------------------------------------------------------------
    1. Backup from Documents -> Red Toshiba & Blue Toshiba
    2. Backup from PHOTOS -> Red Toshiba & Blue Toshiba
    3. Backup from directory on Kingston USB -> Red Toshiba
    4. Backup from directory on Kingston USB -> Blue Toshiba
    0. Quit
    --------------------------------------------------------------
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

    read -r -p "Type an option number. Or type 0 or Q to exit: " option
    case $option in
      1)
        echo "You chose option 1, Backup from Documents -> Red Toshiba & Blue Toshiba."
        check_source
        check_destination
        break
        ;;
      2) 
        echo "You chose option 2, Backup from PHOTOS -> Red Toshiba & Blue Toshiba."
        check_source
        check_destination
        break
        ;;
      3)
        echo "You chose option 3, Backup from directory on Kingston USB -> Red Toshiba."
        check_source
        check_destination
        break
        ;;
      4) 
        echo "You chose option 4, Backup from directory on Kingston USB -> Blue Toshiba"
        check_source
        check_destinationn
        break
        ;;
      0 | [Qq])
        echo "You chose option 0, to Quit."
        break
        ;;
      *)
        echo "Not a valid choice. Type a valid option number."
        sleep 3
        ;;
  esac

    # -a, --archive - archive mode; same as -rlptgoD (no -H). -a implies -r.
    # -v is verbose vs. -q, --quiet - to suppress non-error messages.
    echo "File sync in progress..."
    echo "..."
    rsync -av --exclude={'.Spotlight-V100','.Trashes','.fseventsd'} "$source_path" \
    "$destination_path" && echo "Sync is done."
done

exit 0
