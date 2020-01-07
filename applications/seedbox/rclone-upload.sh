#!/bin/bash
# RClone Config file
RCLONE_CONFIG=/opt/kirios-secrets/rclone.conf
export RCLONE_CONFIG

#exit if running
if [[ "`pidof -x $(basename $0) -o %PPID`" ]]; then exit; fi

# Move older local files to the cloud
/usr/bin/rclone move /mnt/local/ Data: --log-file /home/server/rclone/logs/upload.log -v --exclude-from /opt/kirios/applications/seedbox/excludes --delete-empty-src-dirs --fast-list --max-transfer 700G
