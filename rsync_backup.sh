#! /usr/bin/env bash
#
# Name: rsync_backup.sh
#
# Brief: Bash script that uses rsync to backup files from a specific directory  
# on laptop or  USB drive to external hard drives. This script:
# - includes user prompts, since including or excluding a trailing / is tricky,
# when entering the source & destination/target.
# - prevents creation of unwanted duplicated sub-directories.
#
# Author: Kim Lew

# For SOURCE: State the specific sub-directory WITHOUT /.
# For DESTINATION (target): Do NOT state specific sub-directory, BUT add a /.

# Note: rsync is smart enough to create the sub-directory, if it doesn't already
# exist, & transfers contents. 
# If sub-directory already exists, rsync just transfers contents.

# Limitation: Only 2 USB ports on laptop, therefore:
# To backup USB drive to Red HD: Connect USB drive, connect Red HD & run script with option 3.
# To backup USB drive to Blue HD: Connect USB drive, connect Blue HD & run script with option 4.

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

  echo "# of files, dirs, symlinks, etc. in" "$source_or_dest" "is: " "$number_of_files"
}

do_backup_for_2_targets() {
  # For Case 1, Documents -> Red & Blue HDs & Case2, PHOTOS -> Red & Blue HDs.
  # Note: Passes these arguments for Documents case, Case 1:
  # source_path_Documents="/Users/kimlew/Documents"
  # dest_red="/Volumes/ToshibaRD/"
  # dest_blue="/Volumes/ToshibaBL/"
  # e.g. do_backup_for_2_targets "$source_path_Documents" "Documents" "$dest_red" "Red_HD" "$dest_blue" "Blue_HD"
  # e.g. do_backup_for_2_targets "$source_path_PHOTOS" "PHOTOS" "$dest_red" "Red_HD" "$dest_blue" "Blue_HD"

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
  > backup_"${source_name}"_to_"${dest_name_red}".txt \
  && echo "BACKUP DONE of $source_name -> $dest_name_red."

  rsync -avi --progress --stats --exclude={'.DocumentRevisions-V100','.TemporaryItems','.Spotlight-V100','.Trashes','.fseventsd'} \
  "$source_path" "$dest_path_blue" \
  > backup_"${source_name}"_to_"${dest_name_blue}".txt \
  && echo "BACKUP DONE of $source_name -> $dest_name_blue."
  echo
}
do_backup_for_1_target() {
  # For Case 3, Black USB -> Red HD & Case 4, Black USB -> Blue HD.
  # e.g. do_backup_for_1_target "$source_path_black_usb" "Black_USB" "$dest_red" "Red_HD"
  # e.g. do_backup_for_1_target "$source_path_black_usb" "Black_USB" "$dest_blue" "Blue_HD"
  local source_path=$1
  local source_name=$2
  
  local dest_path=$3
  local dest_name=$4
  
  echo "BACKUP in progress..."
  echo

  rsync -avi --progress --stats --exclude={'.DocumentRevisions-V100','.TemporaryItems','.Spotlight-V100','.Trashes','.fseventsd'} \
  "$source_path" "$dest_path" \
  > backup_"${source_name}"_to_"${dest_name}".txt \
  && echo "BACKUP DONE of $source_name -> $dest_name."
  echo
}
calculate_processing_time() {
  local time_end=$1
  time_diff=$((time_end - time_start))
  echo "Processing Time:" $((time_diff/60)) "min(s)" $((time_diff%60)) "sec(s)"
  echo
}

while true
do
clear

cat <<MENU
BACKUP the Contents from a Directory on your Laptop to a Storage Device
-----------------------------------------------------------------------
1. Backup laptop's Documents folder -> Red & Blue Hard Drives
2. Backup laptop's PHOTOS folder -> Red & Blue Hard Drives
3. Backup Black USB -> Red Hard Drive
4. Backup Black USB -> Blue Hard Drive
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
    # contents to destination/target. Prevents copying a repeated directory.
    # Specifically here, copies from last item in source path to target's root &
    # creates the directory, if it doesn't already exist, e.g., creates Documents
    # directory under /Volumes/ToshibaRD/, if there isn't one already .
    source_path_Documents="/Users/kimlew/Documents"
    # source_path_Documents="/Users/kimlew/Documents/computer_website_camera_info/Camera/Canon_Rebel_T3i_Esst_Train_2011"
    source_path_PHOTOS="/Users/kimlew/PHOTOS"
    source_path_black_usb="/Volumes/Kingston16"
    # "/Volumes/Kingston16/test_King_to_ToshibaBL"
    # "/Volumes/Kingston16/test_King_to_ToshibaRD"
    
    dest_red="/Volumes/ToshibaRD/"
    dest_blue="/Volumes/ToshibaBL/"

    time_start=$(date +%s)

    case $option in
      1)
        echo "YOU CHOSE: 1. Backup laptop's Documents folder -> Red & Blue Hard Drives"
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
        do_backup_for_2_targets "$source_path_Documents" "Documents" "$dest_red" "Red_HD" "$dest_blue" "Blue_HD"

        echo "AFTER BACKUP: "
        num_of_files_in_dest_red_after_backup=$(count_files_dirs_etc "$dest_red")
        print_number_of_files "$dest_red" "$num_of_files_in_dest_red_after_backup"
        num_of_files_in_dest_blue_after_backup=$(count_files_dirs_etc "$dest_blue")
        print_number_of_files "$dest_blue" "$num_of_files_in_dest_blue_after_backup"

        transferred_files_dirs_to_red=$((num_of_files_in_dest_red_after_backup - num_of_files_in_dest_red_before_backup))
        transferred_files_dirs_to_blue=$((num_of_files_in_dest_blue_after_backup - num_of_files_in_dest_blue_before_backup))
        updated_files_dirs_to_red=$(grep '^Number of files transferred' backup_Documents_to_RedHD.txt | sed -E 's/^.*transferred: //')
        updated_files_dirs_to_blue=$(grep '^Number of files transferred' backup_Documents_to_BlueHD.txt | sed -E 's/^.*transferred: //')
        
        echo "New files transferred to $dest_red: " "$transferred_files_dirs_to_red"
        echo "New files transferred to $dest_blue: " "$transferred_files_dirs_to_blue"
        echo "Updated files to $dest_red: " "$updated_files_dirs_to_red"
        echo "Updated files to $dest_blue: " "$updated_files_dirs_to_blue"

        time_end=$(date +%s)
        calculate_processing_time "$time_end"
        break
        ;;
      2) 
        echo "YOU CHOSE: 2. Backup laptop's PHOTOS folder -> Red & Blue Hard Drives"
        echo "Source is: " "$source_path_PHOTOS"
        echo "Destination is: " "$dest_red"
        echo "Destination is: " "$dest_blue"
        echo

        check_if_directory "$source_path_PHOTOS"
        check_if_directory "$dest_red"
        check_if_directory "$dest_blue"

        echo "BEFORE BACKUP: "
        num_of_files_in_dest_red_before_backup=$(count_files_dirs_etc "$dest_red")
        print_number_of_files "$dest_red" "$num_of_files_in_dest_red_before_backup"

        num_of_files_in_dest_blue_before_backup=$(count_files_dirs_etc "$dest_blue")
        print_number_of_files "$dest_blue" "$num_of_files_in_dest_blue_before_backup" 
        echo

        do_backup_for_2_targets "$source_path_PHOTOS" "PHOTOS" "$dest_red" "Red_HD" "$dest_blue" "Blue_HD"

        echo "AFTER BACKUP: "
        num_of_files_in_dest_red_after_backup=$(count_files_dirs_etc "$dest_red")
        print_number_of_files "$dest_red" "$num_of_files_in_dest_red_after_backup"
        num_of_files_in_dest_blue_after_backup=$(count_files_dirs_etc "$dest_blue")
        print_number_of_files "$dest_blue" "$num_of_files_in_dest_blue_after_backup"

        transferred_files_dirs_to_red=$((num_of_files_in_dest_red_after_backup - num_of_files_in_dest_red_before_backup))
        transferred_files_dirs_to_blue=$((num_of_files_in_dest_blue_after_backup - num_of_files_in_dest_blue_before_backup))
        updated_files_dirs_to_red=$(grep '^Number of files transferred' backup_PHOTOS_to_RedHD.txt | sed -E 's/^.*transferred: //')
        updated_files_dirs_to_blue=$(grep '^Number of files transferred' backup_PHOTOS_to_BlueHD.txt | sed -E 's/^.*transferred: //')
        
        echo "New files transferred to $dest_red: " "$transferred_files_dirs_to_red"
        echo "New files transferred to $dest_blue: " "$transferred_files_dirs_to_blue"
        echo "Updated files to $dest_red: " "$updated_files_dirs_to_red"
        echo "Updated files to $dest_blue: " "$updated_files_dirs_to_blue"

        time_end=$(date +%s)
        calculate_processing_time "$time_end"
        break
        ;;
      3)
        echo "YOU CHOSE: 3. Backup Black USB -> Red Hard Drive"
        # If the function call is successful, it continues with next line.
        # If the function call is UNsuccessful, the function already gave user
        # an invalid directory message & quit the process, so you have to choose
        # a menu item again.
        echo "Source is: " "$source_path_black_usb"
        echo "Destination is :" "$dest_red"
        echo

        check_if_directory "$source_path_black_usb"
        check_if_directory "$dest_red"

        echo "BEFORE BACKUP: "
        num_of_files_in_dest_red_before_backup=$(count_files_dirs_etc "$dest_red")
        print_number_of_files "$dest_red" "$num_of_files_in_dest_red_before_backup"
        echo
        
        do_backup_for_1_target "$source_path_black_usb" "Black_USB" "$dest_red" "Red_HD"

        echo "AFTER BACKUP: "
        num_of_files_in_dest_red_after_backup=$(count_files_dirs_etc "$dest_red")
        print_number_of_files "$dest_red" "$num_of_files_in_dest_red_after_backup"

        transferred_files_dirs_to_red=$((num_of_files_in_dest_red_after_backup - num_of_files_in_dest_red_before_backup))
        updated_files_dirs_to_red=$(grep '^Number of files transferred' backup_Black_USB_to_Red_HD.txt | sed -E 's/^.*transferred: //')

        echo "New files transferred to $dest_red: " "$transferred_files_dirs_to_red"
        echo "Updated files to $dest_red: " "$updated_files_dirs_to_red"

        time_end=$(date +%s)
        calculate_processing_time "$time_end"
        break
        ;;
      4) 
        echo "YOU CHOSE: 4. Backup Black USB -> Blue Hard Drive"
        echo "Source is: " "$source_path_black_usb"
        echo "Destination is: " "$dest_blue"
        echo

        check_if_directory "$source_path_black_usb"
        check_if_directory "$dest_blue"

        echo "BEFORE BACKUP: "
        num_of_files_in_dest_blue_before_backup=$(count_files_dirs_etc "$dest_blue")
        print_number_of_files "$dest_blue" "$num_of_files_in_dest_blue_before_backup"
        echo
        
        black_usb_name="Black_USB"
        blue_drive_name="Blue_HD"
        do_backup_for_1_target "$source_path_black_usb" "$black_usb_name" "$dest_blue" "$blue_drive_name"

        echo "AFTER BACKUP: "
        num_of_files_in_dest_blue_after_backup=$(count_files_dirs_etc "$dest_blue")
        print_number_of_files "$dest_blue" "$num_of_files_in_dest_blue_after_backup"

        transferred_files_dirs_to_blue=$((num_of_files_in_dest_blue_after_backup - num_of_files_in_dest_blue_before_backup))
        updated_files_dirs_to_blue=$(grep '^Number of files transferred' backup_"${black_usb_name}"_to_"${blue_drive_name}".txt | sed -E 's/^.*transferred: //')

        echo "New files transferred to $dest_blue: " "$transferred_files_dirs_to_blue"
        echo "Updated files to $dest_blue: " "$updated_files_dirs_to_blue"

        time_end=$(date +%s)
        calculate_processing_time "$time_end"
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
