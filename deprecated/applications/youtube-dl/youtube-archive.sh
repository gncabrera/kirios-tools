#!/bin/bash

#/usr/local/bin/youtube-dl --config-location /mnt/data/YouTube/youtube-dl.conf -o "/mnt/data/YouTube/Playlists/%(playlist)s/%(playlist)s - S01E%(playlist_index)s - %(title)s [%(id)s].%(ext)s" --batch-file=/mnt/data/YouTube/playlist_list.txt

/usr/local/bin/youtube-dl --config-location /opt/kirios/applications/youtube-dl/youtube-dl.conf -o "~/YouTube/%(uploader)s/%(playlist)s/%(playlist)s - S01E%(playlist_index)s - %(title)s [%(id)s].%(ext)s" --batch-file=/opt/kirios/applications/youtube-dl/channel_list.txt