 #! /usr/bin/env bash
#
# Name: bash_rsync.sh
#
# Brief: Bash script with user prompts so user does not forget what to enter as
# source and destination, since it is a bit tricky. Otherwise, you can easily 
# end up with extra directories you did not want. 
# 
# Author: Kim Lew

# Display user prompts of what to enter.
echo "Type the source directory path & include specific directory\
(/Users/kimlew/Documents):"
read source_path

echo "Type the destination directory path but LEAVE OFF specific directory name\
( /Volumes/Toshiba\ Ext\ Drv/):"
read destination_path

echo "Source path you typed is: $source_path"
echo "Destination path you typed is: $destination_path"

# Check for valid directory path for source.
# Check for valid directory path for destination.
if [ ! -d "$source_path" ] 
then
    echo "This directory does NOT exist."
    exit 1
fi
if [ ! -d "$destination_path" ] 
then
    echo "This directory does NOT exist."
    exit 1
fi

echo "File sync in progress..."
echo "..."
rsync -av $source $destination

done
echo "Done."
