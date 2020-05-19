#!/bin/bash
# RClone Config file
RCLONE_CONFIG=/opt/kirios-secrets/rclone.conf
export RCLONE_CONFIG

#exit if running
if [[ "`pidof -x $(basename $0) -o %PPID`" ]]; then exit; fi

# Move older local files to the cloud
/usr/bin/rclone copy Data: /mnt/media --log-file /var/log/rclone/download.log -v --fast-list --max-transfer 200G
