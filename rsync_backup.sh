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
# -e - tests if a path exists without testing what type of file it is.
check_if_directory() {
    path_given=$1
    # echo "path_given is:" "$1"
    # The : colon here is returned after the function call. 
    # Could: For troubleshooting, redirect line to standard error so standard input doesn't get return values.
    # 

    if [ ! -d "$path_given" ]; then
        echo "This directory" "$path_given" "does NOT exist."
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
    3. Backup from directory on Black Kingston USB -> Red Toshiba
    4. Backup from directory on Black Kingston USB -> Blue Toshiba
    0. Quit
    --------------------------------------------------------------
MENU

    # Custom user prompt. 
    PS3="Which backup are you doing? Type 1 to 4, or 0 to quit: "

    # -r - interpret backslash as part of the line, NOT as escape char.
    # -p - execute read using prompt
    read -r -p "Type an option number. Or type 0 or Q to exit: " option

    # Note: NO trailing \ on source directories - so ONLY copies directory
    # contents to destination. Prevents copying a repeated directory.
    source_path_Documents="/Users/kimlew/Documents"
    source_path_PHOTOS="/Users/kimlew/PHOTOS"
    source_path_black_usb="/Volumes/Kingston16"
    
    dest_red="/Volumes/ToshibaRD/"
    dest_blue="/Volumes/ToshibaBL/"

    case $option in
      1)
        echo "You chose option 1, Backup from Documents -> Red Toshiba & Blue Toshiba."
        source_path_Documents_valid=$(check_source "$source_path_Documents")
        dest_path_red_valid=$(check_destination "$dest_red")
        dest_path_blue_valid=$(check_destination "$dest_blue")

        if [[ "$source_path_Documents_valid" == true && "$dest_path_red_valid" == true ]]; then
            # -a, --archive - archive mode; same as -rlptgoD (no -H). -a implies -r.
            # -v is verbose vs. -q, --quiet - to suppress non-error messages.
            echo "Backup in progress..."
            echo "..."
            rsync -av --exclude={'.Spotlight-V100','.Trashes','.fseventsd'} \
            "$source_path_Documents" "$dest_red" \
            && echo "Done Documents backup to Red Toshiba."
        fi
        if [[ "$source_path_Documents_valid" == true && "$dest_path_blue_valid" == true ]]; then
            echo "Backup in progress..."
            echo "..."
            rsync -av --exclude={'.Spotlight-V100','.Trashes','.fseventsd'} \
            "$source_path_Documents" "$dest_blue" \
            && echo "Done Documents backup to Blue Toshiba."
        fi
        break
        ;;
      2) 
        echo "You chose option 2, Backup from PHOTOS -> Red Toshiba & Blue Toshiba."
        source_path_PHOTOS_valid=$(check_source "$source_path_PHOTOS")
        dest_path_red_valid=$(check_destination "$dest_red")
        dest_path_blue_valid=$(check_destination "$dest_blue")

        if [[ "$source_path_PHOTOS_valid" == true && "$dest_path_red_valid" == true ]]; then
            # -a, --archive - archive mode; same as -rlptgoD (no -H). -a implies -r.
            # -v is verbose vs. -q, --quiet - to suppress non-error messages.
            echo "Backup in progress..."
            echo "..."
            rsync -av --exclude={'.Spotlight-V100','.Trashes','.fseventsd'} \
            "$source_path_PHOTOS" "$dest_red" \
            && echo "Done PHOTOS backup to Red Toshiba."
        fi
        if [[ "$source_path_PHOTOS_valid" == true && "$dest_path_blue_valid" == true ]]; then
            echo "Backup in progress..."
            echo "..."
            rsync -av --exclude={'.Spotlight-V100','.Trashes','.fseventsd'} \
            "$source_path_PHOTOS" "$dest_blue" \
            && echo "Done PHOTOS backup to Blue Toshiba."
        fi
        break
        ;;
      3)
        echo "You chose option 3, Backup from directory on Kingston USB -> Red Toshiba."
        # If the function call is successful, it continues with next line.
        # If the function call is UNsuccessful, the function already gave user
        # an invalid directory message & quit the process, so you have to choose
        # a menu item again.
        echo "Source is: " "$source_path_black_usb"
        echo "Destination is: " "$dest_red"
        check_if_directory "$source_path_black_usb"
        check_if_directory "$dest_red"

        echo "BACKUP in progress..."
        rsync -av --exclude={'.Spotlight-V100','.Trashes','.fseventsd'} \
        "$source_path_black_usb" "$dest_red" \
        && echo "DONE backup from Black Kingston USB to Red Toshiba."
        break
        ;;
      4) 
        echo "You chose option 4, Backup from directory on Kingston USB -> Blue Toshiba"
        source_path_black_usb_valid=$(check_source "$source_path_black_usb")
        dest_path_blue_valid=$(check_destination "$dest_blue")

        if [[ "$source_path_black_usb_valid" == true && "$dest_path_blue_valid" == true ]]; then
            echo "Backup in progress..."
            echo "..."
            rsync -av --exclude={'.Spotlight-V100','.Trashes','.fseventsd'} \
            "$source_path_black_usb_valid" "$dest_path_blue_valid" \
            && echo "Done backup from Black Kingston USB to Blue Toshiba."
        fi
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
done
echo
exit 0
