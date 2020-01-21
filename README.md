## Bash script using rsync to backup folders and files on local drive to external device

Name: `bash_rsync.sh`

Bash script that uses rsync to backup files and folders from computer to external hard drive, USB drive, etc. 
- Script includes user prompts since including or excluding a trailing / is tricky when entering the source and destination/target.
- Otherwise, use can easily end up with extra unwanted sub-directories.
