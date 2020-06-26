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
# For SOURCE: State the specific sub-directory WITHOUT /.
# For DESTINATION (target): Do NOT state specific sub-directory, BUT add a /.

# Note: rsync is smart enough to create the sub-directory, if it doesn't already
# exist, & transfers contents. 
# If sub-directory already exists, rsync just transfers contents.

# Limitation: Only 2 USB ports on laptop, therefore:
# To backup USB drive to Red HD: Connect USB drive, connect Red HD & run script with option 3.
# To backup USB drive to Blue HD: Connect USB drive, connect Blue HD & run script with option 4.

# Author: Kim Lew

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

  echo "# of files, dirs, symlinks, etc. in ${source_or_dest} is: ${number_of_files}"
}

do_backup_for_2_targets() {
  # For Case 1, Documents -> Red & Blue HDs & Case2. Passes in:
  # e.g. do_backup_for_2_targets "$source_path_Documents" "$Documents_dir_name"
  # For Case 2, PHOTOS -> Red & Blue HDs. Passes in:
  # e.g. do_backup_for_2_targets "$source_path_PHOTOS" "$PHOTOS_dir_name"
  local source_path=$1
  local source_name=$2
  
  echo "$before_backup "
  num_of_files_in_dest_red_before_backup=$(count_files_dirs_etc "$dest_red")
  print_number_of_files "$dest_red" "$num_of_files_in_dest_red_before_backup"

  num_of_files_in_dest_blue_before_backup=$(count_files_dirs_etc "$dest_blue")
  print_number_of_files "$dest_blue" "$num_of_files_in_dest_blue_before_backup" 
  echo
  echo "$backup_started"

  # -a, --archive - archive mode; same as -rlptgoD (no -H). -a implies -r.
  # -v is verbose vs. -q, --quiet - to suppress non-error messages.
  rsync -avi --progress --stats --exclude={'.DocumentRevisions-V100','.TemporaryItems','.Spotlight-V100','.Trashes','.fseventsd'} \
  "${source_path}" "${dest_red}" \
  > backup_"${source_name}"_to_"${red_drive_name}".txt \
  && echo "${backup_in_progress}" "${source_name}" "->" "${red_drive_name}"

  rsync -avi --progress --stats --exclude={'.DocumentRevisions-V100','.TemporaryItems','.Spotlight-V100','.Trashes','.fseventsd'} \
  "${source_path}" "${dest_blue}" \
  > backup_"${source_name}"_to_"${blue_drive_name}".txt \
  && echo "${backup_in_progress}" "${source_name}" "->" "${blue_drive_name}"
  echo
  echo "$after_backup"
  post_backup_summary "$num_of_files_in_dest_red_before_backup" "$source_path" "$source_name" "$dest_red" "$red_drive_name"
  post_backup_summary "$num_of_files_in_dest_blue_before_backup" "$source_path" "$source_name" "$dest_blue" "$blue_drive_name"
}

do_backup_for_1_target() {
  # For Case 3, Black USB -> Red HD & Case 4, Black USB -> Blue HD. Passes in:
  # source_path_black_usb="/Volumes/Kingston16"
  # dest_red="/Volumes/ToshibaRD/" OR dest_blue="/Volumes/ToshibaBL/"
  # e.g. do_backup_for_1_target "$source_path_black_usb" "$black_usb_name" "$dest_red" "$red_drive_name"
  # e.g. do_backup_for_1_target "$source_path_black_usb" "$black_usb_name" "$dest_blue" "$blue_drive_name"
  local source_path=$1
  local source_name=$2
  
  local dest_path=$3
  local dest_name=$4
  
  echo "$before_backup"
  
  local num_of_files_in_dest_before_backup
  num_of_files_in_dest_before_backup="$(count_files_dirs_etc "$dest_path")"
  print_number_of_files "$dest_path" "$num_of_files_in_dest_before_backup"
  echo

  echo "$backup_started"
  rsync -avi --progress --stats --exclude={'.DocumentRevisions-V100','.TemporaryItems','.Spotlight-V100','.Trashes','.fseventsd'} \
  "${source_path}" "${dest_path}" \
  > backup_"${source_name}"_to_"${dest_name}".txt \
  && echo "${backup_in_progress}" "${source_name}" "->" "${dest_name}"
  echo

  echo "$after_backup"
  post_backup_summary "$num_of_files_in_dest_before_backup" "$source_path" "$source_name" "$dest_path" "$dest_name"
}
post_backup_summary() {
  # e.g. post_backup_summary "$num_of_files_in_dest_blue_before_backup" "source_path_black_usb" "$black_usb_name" "$dest_blue" "$blue_drive_name"
  local num_of_files_in_dest_before_backup=$1
  local source_path=$2
  local source_name=$3
  local dest_path=$4
  local dest_name=$5

  num_of_files_in_dest_after_backup=$(count_files_dirs_etc "$dest_path")
  print_number_of_files "$dest_path" "$num_of_files_in_dest_after_backup"

  transferred_files_dirs_to_dest=$((num_of_files_in_dest_after_backup - num_of_files_in_dest_before_backup))
  updated_files_dirs_to_dest=$(grep '^Number of files transferred' backup_"${source_name}"_to_"${dest_name}".txt | sed -E 's/^.*transferred: //')

  echo "New files transferred to ${dest_name} is: ${transferred_files_dirs_to_dest}"
  echo "Updated files to ${dest_name} is: ${updated_files_dirs_to_dest}"
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
    # -p - execute read using prompt.
    read -r -p "Type an option number. Or type 0 or Q to exit: " option
    echo

    # Note: NO trailing / on source directories - so ONLY copies directory
    # contents to destination/target. Prevents copying a repeated directory.
    # Specifically here, copies from last item in source path to target's root &
    # creates the directory, if it doesn't already exist, e.g., creates Documents
    # directory under /Volumes/ToshibaRD/, if there isn't one already.
    source_path_Documents="/Users/kimlew/Documents"
    source_path_PHOTOS="/Users/kimlew/PHOTOS"
    source_path_black_usb="/Volumes/Kingston16"
    
    dest_red="/Volumes/ToshibaRD/"
    dest_blue="/Volumes/ToshibaBL/"

    Documents_dir_name="Documents"
    PHOTOS_dir_name="PHOTOS"
    black_usb_name="Black_USB"
    red_drive_name="Red_HD"
    blue_drive_name="Blue_HD"

    before_backup="BEFORE BACKUP:"
    after_backup="AFTER BACKUP:"
    src_is="Source is:"
    dest_is="Destination is:"
    backup_started="BACKUP started..."
    backup_in_progress="BACKUP in progress of"

    time_start=$(date +%s)

    case $option in
      1)
        echo "YOU CHOSE: 1. Backup Documents folder -> Red & Blue Hard Drives"
        echo "$src_is" "$source_path_Documents"
        echo "$dest_is" "$dest_red"
        echo "$dest_is" "$dest_blue"
        echo
        check_if_directory "$source_path_Documents"
        check_if_directory "$dest_red"
        check_if_directory "$dest_blue"
        # Pass arguments with paths & "nice" names with function call, e.g.,
        # do_backup "$source_path_Documents" "$nicename1"
        do_backup_for_2_targets "$source_path_Documents" "$Documents_dir_name"
        break
        ;;
      2) 
        echo "YOU CHOSE: 2. Backup PHOTOS folder -> Red & Blue Hard Drives"
        echo "$src_is" "$source_path_PHOTOS"
        echo "$dest_is" "$dest_red"
        echo "$dest_is" "$dest_blue"
        echo
        check_if_directory "$source_path_PHOTOS"
        check_if_directory "$dest_red"
        check_if_directory "$dest_blue"
        do_backup_for_2_targets "$source_path_PHOTOS" "$PHOTOS_dir_name"
        break
        ;;
      3)
        echo "YOU CHOSE: 3. Backup Black USB -> Red Hard Drive"
        echo "$src_is" "$source_path_black_usb"
        echo "$dest_is" "$dest_red"
        echo
        check_if_directory "$source_path_black_usb"
        check_if_directory "$dest_red"
        do_backup_for_1_target "$source_path_black_usb" "$black_usb_name" "$dest_red" "$red_drive_name"
        break
        ;;
      4) 
        echo "YOU CHOSE: 4. Backup Black USB -> Blue Hard Drive"
        echo "$src_is" "$source_path_black_usb"
        echo "$dest_is" "$dest_blue"
        echo
        check_if_directory "$source_path_black_usb"
        check_if_directory "$dest_blue"
        do_backup_for_1_target "$source_path_black_usb" "$black_usb_name" "$dest_blue" "$blue_drive_name"
        break
        ;;
      0 | [Qq])
        echo "You chose: 0. Quit"
        exit 1
        ;;
      *)
        echo "Not a valid choice. Type a valid option number."
        sleep 3
        ;;
  esac
done

time_end=$(date +%s)
calculate_processing_time "$time_end"

exit 0
