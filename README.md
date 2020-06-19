# Bash script using rsync to backup a folder or entire USB to external drives

Name: `rsync_backup.sh`

Bash script that uses rsync to backup from:

- a specific directory on computer - to external hard drive or
- a USB drive - to an external hard drive

Script:

- includes menu of options
- eliminates confusing/tricky part of when to include or exclude a trailing / especially when you enter the source & destination/target
- prevents creation of unwanted duplicate sub-directories
