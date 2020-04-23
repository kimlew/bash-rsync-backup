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
  path_passed_in=$1

  if [ ! -d "$path_passed_in" ]; then
      echo "This directory does NOT exist:" "$path_passed_in"
      echo "Make sure drive is plugged in."
      exit 1
  fi
}

count_files() {
  path_passed_in=$1
  find "${path_passed_in%/}" -type f 2> /dev/null | wc -l

  if [ ! -d "$path_passed_in" ]; then
    echo "There are NO files at this path" "$path_passed_in"
    exit 1
  fi
}

count_files_dirs_etc() {
  path_passed_in=$1
  find "${path_passed_in%/}" 2> /dev/null | wc -l

  if [ ! -d "$path_passed_in" ]; then
    echo "There are NO files, directories, symlinks, etc. at this path" "$path_passed_in"
    exit 1
  fi
}

while true
do
clear

cat <<MENU
BACKUP the Contents from a Directory on your Laptop to a Storage Device
-----------------------------------------------------------------------
1. Backup laptop's Documents folder -> Red Toshiba & Blue Toshiba
2. Backup laptop's PHOTOS folder -> Red Toshiba & Blue Toshiba
3. Backup Black Kingston USB -> Red Toshiba
4. Backup Black Kingston USB -> Blue Toshiba
0. Quit
-----------------------------------------------------------------------
MENU

    # Custom user prompt. 
    PS3="Which backup are you doing? Type 1 to 4, or 0 to quit: "

    # -r - interpret backslash as part of the line, NOT as escape char.
    # -p - execute read using prompt
    read -r -p "Type an option number. Or type 0 or Q to exit: " option
    echo

    # Note: NO trailing \ on source directories - so ONLY copies directory
    # contents to destination. Prevents copying a repeated directory.
    source_path_Documents="/Users/kimlew/Documents"
    # "/Users/kimlew/Documents/test_Documents_to_ToshibaRD"
    source_path_PHOTOS="/Users/kimlew/PHOTOS"
    source_path_black_usb="/Volumes/Kingston16"
    # "/Volumes/Kingston16/test_King_to_ToshibaBL"
    # "/Volumes/Kingston16/test_King_to_ToshibaRD"
    
    dest_red="/Volumes/ToshibaRD/"
    dest_blue="/Volumes/ToshibaBL/"

    time_start=$(date +%s)

    case $option in
      1)
        echo "You chose: 1. Backup laptop's Documents folder -> Red Toshiba & Blue Toshiba"
        echo "Source is: " "$source_path_Documents"
        echo "Destination is: " "$dest_red"
        echo "Destination is: " "$dest_blue"
        echo

        check_if_directory "$source_path_Documents"
        check_if_directory "$dest_red"
        check_if_directory "$dest_blue"

        number_of_files_in_src=$(count_files "$source_path_Documents")
        echo "Number of files in Documents: " "$number_of_files_in_src"
        number_of_files_dirs_etc_in_src=$(count_files_dirs_etc "$source_path_Documents")
        echo "Number of files, dirs, symlinks, etc. in Documents: " "$number_of_files_dirs_etc_in_src"
        echo

        echo "BEFORE BACKUP: "
        number_of_files_in_dest_red=$(count_files "$dest_red")
        echo "Number of files in RED HD dest path: " "$number_of_files_in_dest_red"
        number_of_files_dirs_etc_in_dest_red=$(count_files_dirs_etc "$dest_red")
        echo "Number of files, dirs, symlinks, etc. in RED HD dest path: " "$number_of_files_dirs_etc_in_dest_red"
        echo

        number_of_files_in_dest_blue=$(count_files "$dest_blue")
        echo "Number of files in BLUE HD dest path: " "$number_of_files_in_dest_blue"
        number_of_files_dirs_etc_in_dest_blue=$(count_files_dirs_etc "$dest_blue")
        echo "Number of files, dirs, symlinks, etc., in BLUE HD dest path: " "$number_of_files_dirs_etc_in_dest_blue"
        echo
        
        echo "BACKUP in progress..."
        echo
        
        # -a, --archive - archive mode; same as -rlptgoD (no -H). -a implies -r.
        # -v is verbose vs. -q, --quiet - to suppress non-error messages.
        # > dry-run_Documents_to_RedHD.txt \
        rsync -avi --progress --stats --exclude={'.DocumentRevisions-V100','.TemporaryItems','.Spotlight-V100','.Trashes','.fseventsd'} \
        "$source_path_Documents" "$dest_red" \
        > backup_Documents_to_RedHD.txt \
        && echo "BACKUP DONE of Documents -> Red Toshiba."
      
        rsync -avi --progress --stats --exclude={'.DocumentRevisions-V100','.TemporaryItems','.Spotlight-V100','.Trashes','.fseventsd'} \
        "$source_path_Documents" "$dest_blue" \
        > backup_Documents_to_BlueHD.txt \
        && echo "BACKUP DONE of Documents -> Blue Toshiba."
        echo

        echo "AFTER BACKUP: "
        number_of_files_in_dest_red_after_backup=$(find "${dest_red%/}" -type f 2> /dev/null | wc -l)
        echo "Number of files in RED HD dest path: " "$number_of_files_in_dest_red_after_backup"
        number_of_files_dirs_etc_in_dest_red_after_backup=$(find "${dest_red%/}" 2> /dev/null | wc -l)
        echo "Number of files, dirs, symlinks, etc. in RED HD dest path: " "$number_of_files_dirs_etc_in_dest_red_after_backup"
        echo

        number_of_files_in_dest_blue_after_backup=$(find "${dest_blue%/}" -type f 2> /dev/null | wc -l)
        echo "Number of files in BLUE HD dest path: " "$number_of_files_in_dest_blue_after_backup"
        number_of_files_dirs_etc_in_dest_blue_after_backup=$(find "${dest_blue%/}" 2> /dev/null | wc -l)
        echo "Number of files, dirs, symlinks, etc. in BLUE HD dest path: " "$number_of_files_dirs_etc_in_dest_blue_after_backup"
        echo
        
        transferred_files_to_red=$((number_of_files_in_dest_red_after_backup-number_of_files_in_dest_red))
        transferred_files_to_blue=$((number_of_files_in_dest_blue_after_backup-number_of_files_in_dest_blue))
        echo "TOTAL files transferred to RED: " "$transferred_files_to_red"
        echo "TOTAL files transferred to BLUE: " "$transferred_files_to_blue"

        transferred_files_to_red_way2=$((number_of_files_dirs_etc_in_dest_red_after_backup - number_of_files_dirs_etc_in_dest_red))
        transferred_files_to_blue_way2=$((number_of_files_dirs_etc_in_dest_blue_after_backup - number_of_files_dirs_etc_in_dest_blue))
        echo "TOTAL files transferred to RED way2: " "$transferred_files_to_red_way2"
        echo "TOTAL files transferred to BLUE way2: " "$transferred_files_to_blue_way2"
        echo

        time_end=$(date +%s)
        time_diff=$((time_end - time_start))
        echo "Processing Time:" $((time_diff/60)) "min(s)" $((time_diff%60)) "sec(s)" 
        echo
        break
        ;;
      2) 
        echo "You chose: 2. Backup laptop's PHOTOS folder -> Red Toshiba & Blue Toshiba"
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
        echo "You chose: 3. Backup Black Kingston USB -> Red Toshiba"
        # If the function call is successful, it continues with next line.
        # If the function call is UNsuccessful, the function already gave user
        # an invalid directory message & quit the process, so you have to choose
        # a menu item again.
        echo "Source is: " "$source_path_black_usb"
        echo "Destination is :" "$dest_red"
        echo

        check_if_directory "$source_path_black_usb"
        check_if_directory "$dest_red"

        count_files "$source_path_black_usb"

        number_of_files_in_src=$(find "${source_path_black_usb%/}" -type f | wc -l)
        echo "Number of files in source path: " "$number_of_files_in_src"
        number_of_files_dirs_etc_in_src=$(find "${source_path_black_usb%/}" | wc -l)
        echo "Number of files, dirs, symlinks, etc. in source path: " "$number_of_files_dirs_etc_in_src"
        echo
        
        echo "BACKUP in progress..."
        echo
        
        rsync -avi --progress --stats --exclude={'.DocumentRevisions-V100','.TemporaryItems','.Spotlight-V100','.Trashes','.fseventsd'} \
        "$source_path_black_usb" "$dest_red" \
        && echo \
        && echo "BACKUP DONE of Black Kingston USB -> Red Toshiba."
        
        time_end=$(date +%s)
        time_diff=$((time_end - time_start))
        echo "Processing files took:" $((time_diff/60)) "min(s)" $((time_diff%60)) "sec(s)" 
        echo
        break
        ;;
      4) 
        echo "You chose: 4. Backup Black Kingston USB -> Blue Toshiba"
        echo "Source is: " "$source_path_black_usb"
        echo "Destination is: " "$dest_blue"
        echo

        check_if_directory "$source_path_black_usb"
        check_if_directory "$dest_blue"

        count_files "$source_path_black_usb"

        number_of_files_in_src=$(find "${source_path_black_usb%/}" -type f | wc -l)
        echo "Number of files in source path: " "$number_of_files_in_src"
        number_of_files_dirs_etc_in_src=$(find "${source_path_black_usb%/}" | wc -l)
        echo "Number of files, dirs, symlinks, etc. in source path: " "$number_of_files_dirs_etc_in_src"
        echo
        
        echo "BACKUP in progress..."
        echo

        rsync -avi --progress --stats --exclude={'.DocumentRevisions-V100','.TemporaryItems','.Spotlight-V100','.Trashes','.fseventsd'} \
        "$source_path_black_usb" "$dest_blue" \
        && echo \
        && echo "BACKUP DONE of Black Kingston USB -> Blue Toshiba."

        time_end=$(date +%s)
        time_diff=$((time_end - time_start))
        echo "Processing files took:" $((time_diff/60)) "min(s)" $((time_diff%60)) "sec(s)" 
        echo
        break
        ;;
      0 | [Qq])
        echo "You chose: 0. Quit"
        break
        ;;
      *)
        echo "Not a valid choice. Type a valid option number."
        sleep 3
        ;;
  esac
done

exit 0
