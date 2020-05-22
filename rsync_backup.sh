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

count_files_dirs_etc() {
  # Counts files, directories, symlinks, etc. in path passed in.
  path_passed_in=$1
  find "${path_passed_in%/}" 2> /dev/null | wc -l
}

print_number_of_files() {
  local source_or_dest=$1
  local number_of_files=$2

  echo "# of files, dirs, symlinks, etc. in: " "$source_or_dest" "is: " "$number_of_files"
}

do_backup_for_2_targets() {
  # For Case 1, Documents & Case2, PHOTOS.
  # Note: Passes for Documents case, Case 1:
  # source_path_Documents="/Users/kimlew/Documents"
  # dest_red="/Volumes/ToshibaRD/"
  # dest_blue="/Volumes/ToshibaBL/"
  # Called: do_backup "$source_path_Documents" "Documents" "$dest_red" "Red Toshiba Hard Drive" "$dest_blue" "Blue Toshiba Hard Drive"

  local source_path=$1
  local source_name=$2
  
  local dest_path_red=$3
  local dest_name_red=$4

  local dest_path_blue=$5
  local dest_name_blue=$6
  
  echo "BACKUP in progress..."
  echo

  # -a, --archive - archive mode; same as -rlptgoD (no -H). -a implies -r.
  # -v is verbose vs. -q, --quiet - to suppress non-error messages.
  # > dry-run_Documents_to_RedHD.txt \
  rsync -avi --progress --stats --exclude={'.DocumentRevisions-V100','.TemporaryItems','.Spotlight-V100','.Trashes','.fseventsd'} \
  "$source_path" "$dest_path_red" \
  > backup_Documents_to_RedHD.txt \
  && echo "BACKUP DONE of $source_name -> $dest_name_red."

  rsync -avi --progress --stats --exclude={'.DocumentRevisions-V100','.TemporaryItems','.Spotlight-V100','.Trashes','.fseventsd'} \
  "$source_path" "$dest_path_blue" \
  > backup_Documents_to_BlueHD.txt \
  && echo "BACKUP DONE of $source_name -> $dest_name_blue."
  echo
}
do_backup_for_1_target() {
  local source_path=$1
  local source_name=$2
  
  local dest_path=$3
  local dest_name=$4
  
  echo "BACKUP in progress..."
  echo

  # -a, --archive - archive mode; same as -rlptgoD (no -H). -a implies -r.
  # -v is verbose vs. -q, --quiet - to suppress non-error messages.
  # > dry-run_Documents_to_RedHD.txt \
  rsync -avi --progress --stats --exclude={'.DocumentRevisions-V100','.TemporaryItems','.Spotlight-V100','.Trashes','.fseventsd'} \
  "$source_path" "$dest_path" \
  > backup_USB_to_Hard_Drive.txt \
  && echo "BACKUP DONE of $source_name -> $dest_name."
  echo
  # TODO: Change .txt to increase in number when script runs? How else 2 files?
}

while true
do
clear

cat <<MENU
BACKUP the Contents from a Directory on your Laptop to a Storage Device
-----------------------------------------------------------------------
1. Backup laptop's Documents folder -> Red Toshiba & Blue Toshiba Hard Drives
2. Backup laptop's PHOTOS folder -> Red Toshiba & Blue Toshiba Hard Drives
3. Backup Black Kingston USB -> Red Toshiba Hard Drive
4. Backup Black Kingston USB -> Blue Toshiba Hard Drive
0. Quit
-----------------------------------------------------------------------
MENU

    # Custom user prompt. 
    PS3="Which backup are you doing? Type 1 to 4, or 0 to quit: "

    # -r - interpret backslash as part of the line, NOT as escape char.
    # -p - execute read using prompt
    read -r -p "Type an option number. Or type 0 or Q to exit: " option
    echo

    # Note: NO trailing / on source directories - so ONLY copies directory
    # contents to destination. Prevents copying a repeated directory.
    # source_path_Documents="/Users/kimlew/Documents"
    source_path_Documents="/Users/kimlew/Documents/computer_website_camera_info/Camera/Canon_Rebel_T3i_Esst_Train_2011"
    source_path_PHOTOS="/Users/kimlew/PHOTOS"
    source_path_black_usb="/Volumes/Kingston16"
    # "/Volumes/Kingston16/test_King_to_ToshibaBL"
    # "/Volumes/Kingston16/test_King_to_ToshibaRD"
    
    dest_red="/Volumes/ToshibaRD/"
    dest_blue="/Volumes/ToshibaBL/"

    time_start=$(date +%s)

    case $option in
      1)
        echo "YOU CHOSE: 1. Backup laptop's Documents folder -> Red Toshiba & Blue Toshiba"
        echo "Source is: " "$source_path_Documents"
        echo "Destination is: " "$dest_red"
        echo "Destination is: " "$dest_blue"
        echo

        check_if_directory "$source_path_Documents"
        check_if_directory "$dest_red"
        check_if_directory "$dest_blue"

        echo "BEFORE BACKUP: "
        num_of_files_in_dest_red_before_backup=$(count_files_dirs_etc "$dest_red")
        print_number_of_files "$dest_red" "$num_of_files_in_dest_red_before_backup"

        num_of_files_in_dest_blue_before_backup=$(count_files_dirs_etc "$dest_blue")
        print_number_of_files "$dest_blue" "$num_of_files_in_dest_blue_before_backup" 
        echo
        
        # Pass 6 arguments with call of function, do_backup().
        # Could also do this way:
        # do_backup "$source_path_Documents" "nicename1" "$dest_red" "$nicename1"
        # do_backup "$source_path_Documents" "nicename1" "$dest_blue" "$nicename2"
        do_backup_for_2_targets "$source_path_Documents" "Documents" "$dest_red" "Red Toshiba Hard Drive" "$dest_blue" "Blue Toshiba Hard Drive"

        echo "AFTER BACKUP: "
        num_of_files_in_dest_red_after_backup=$(count_files_dirs_etc "$dest_red")
        print_number_of_files "$dest_red" "$num_of_files_in_dest_red_after_backup"
        num_of_files_in_dest_blue_after_backup=$(count_files_dirs_etc "$dest_blue")
        print_number_of_files "$dest_blue" "$num_of_files_in_dest_blue_after_backup"

        transferred_files_dirs_to_red=$((num_of_files_in_dest_red_after_backup - num_of_files_in_dest_red_before_backup))
        transferred_files_dirs_to_blue_=$((num_of_files_in_dest_blue_after_backup - num_of_files_in_dest_blue_before_backup))
        echo "Total files transferred to $dest_red: " "$transferred_files_dirs_to_red"
        echo "Total files transferred to $dest_blue: " "$transferred_files_dirs_to_blue_"

        time_end=$(date +%s)
        time_diff=$((time_end - time_start))
        echo "Processing Time:" $((time_diff/60)) "min(s)" $((time_diff%60)) "sec(s)"
        echo
        break
        ;;
      2) 
        echo "YOU CHOSE: 2. Backup laptop's PHOTOS folder -> Red Toshiba & Blue Toshiba"
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
        echo "YOU CHOSE: 3. Backup Black Kingston USB -> Red Toshiba"
        # If the function call is successful, it continues with next line.
        # If the function call is UNsuccessful, the function already gave user
        # an invalid directory message & quit the process, so you have to choose
        # a menu item again.
        echo "Source is: " "$source_path_black_usb"
        echo "Destination is :" "$dest_red"
        echo

        check_if_directory "$source_path_black_usb"
        check_if_directory "$dest_red"

        number_of_files_dirs_etc_in_src=$(count_files_dirs_etc "$source_path_black_usb")
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
        echo "YOU CHOSE: 4. Backup Black Kingston USB -> Blue Toshiba"
        echo "Source is: " "$source_path_black_usb"
        echo "Destination is: " "$dest_blue"
        echo

        check_if_directory "$source_path_black_usb"
        check_if_directory "$dest_blue"

        number_of_files_dirs_etc_in_src=$(count_files_dirs_etc "$source_path_black_usb")
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
