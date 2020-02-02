# Bash script using rsync to backup a folder on local drive to external device

Name: `bash_rsync.sh`

Bash script that uses rsync to backup from a specific directory on computer to external hard drive, USB drive, etc.

- Script includes user prompts, since including or excluding a trailing / is tricky, when entering the source & destination/target.
- Prevents: Creation of unwanted duplicated sub-directories.
