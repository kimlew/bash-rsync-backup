# Bash script using rsync to backup a folder or entire USB to external drives

Name: `rsync_backup.sh`

Bash script that uses rsync to backup from:

- a specific directory on computer - to external hard drive or
- a USB drive - to an external hard drive

Script:

- includes user prompts - since including or excluding a trailing / is tricky, especially when entering the source & destination/target
- prevents creation of unwanted duplicate sub-directories
