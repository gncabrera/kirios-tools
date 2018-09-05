#!/usr/bin/env python3

# DESCRIPTION: Generic backup tool. The backups are done with rclone to a gdrive account in a encrypted folder
# DEPENDENCIES: rclone


# Usage example: backup.tool my-super-app volume my-volume --backup-name=my-backup (optional)
# Creates the backup /my-user-app/volume-my-volume_YYYYMMdd_HHmmss.zip

# Usage example: backup.tool folder "/path/to/folder" --app=my-super-app --backup-name=my-backup (optional)
# Creates the backup /my-user-app/folder_YYYYMMdd_HHmmss.zip

import argparse
import subprocess
import os
import json
import socket
import time
import re
from glob import glob
from itertools import islice
import datetime
import pathlib
import shutil

VERSION = '1.0.0'
VOLUME = 'volume'
FOLDER = 'folder'
FILE = 'file'
LATEST_FILE = ''

parser = argparse.ArgumentParser(description='Restore tool(https://kirios.co)')
parser.add_argument('application', help = 'name of the application to restore')
parser.add_argument('type', choices=[VOLUME, FOLDER, FILE], help = 'type of data that will be restored')
parser.add_argument('target', help='target that will be restored (folder, Docker volume, etc.)')
parser.add_argument('--version', action='version', version = VERSION)
parser.add_argument('--filename', required=True, help = 'name of the file to restore. For example my-volume_YYYYMMdd_HHmmss.zip')
parser.add_argument('--folder', default = '', help = 'folder where the backup is stored. By default is /{application}/')

args = parser.parse_args()

def runShellCommand(command):
    print('Executing - ' + command)
    return subprocess.call(command, shell = True)

# Returns the base filename to search in the remote folder
def get_basefilename():
    return args.filename

# Returns the latest file starting with {get_basefilename}*

def get_latest_filename():
    global LATEST_FILE
    if not LATEST_FILE:
        base_filename = get_basefilename()
        
        command = "rclone lsjson " + get_remotefolder() + " --config /opt/kirios/applications/rclone/rclone.conf --no-modtime"
        print('Executing - ' + command)
        stdout = subprocess.getoutput(command)
        file_list = json.loads(stdout)
        sorted_list = sorted(file_list, key=lambda f: f["Name"])
        filtered_list = list(filter(lambda f : f["Name"].startswith(base_filename), sorted_list))
        LATEST_FILE = filtered_list[-1]
    
    return LATEST_FILE["Name"]

# Returns the remote folder
def get_remotefolder():
    foldername = args.folder if args.folder else args.application
    return 'backup:' + foldername + "/" + get_basefilename()

# Returns the full path of the remote file to download
def get_remotepath():
    return get_remotefolder() + '/' + get_latest_filename()

# Returns the folder where to put the downloaded file
def get_localfolder():
    return '/tmp'

# Returns the full path of the downloaded file 
def get_localpath():
    return get_localfolder() + '/' + get_latest_filename()
     
def print_overview():
    print('')
    print('Starting restore process for the application ' + args.application + ': ' + args.type + ' ' + args.target)
    print('The file to restore is ' + get_remotepath())
    print('')


print_overview()

print("Dowloading compressed file [" + get_remotepath() + "] to [" + get_localpath() +"]")
runShellCommand('rclone copy ' + get_remotepath() +' '+ get_localfolder() + ' -v --config=/opt/kirios/applications/rclone/rclone.conf')

if(args.type == FOLDER):
    print("Extracting tar file: " + get_localpath())
    os.makedirs(args.target, exist_ok=True)
    runShellCommand('tar -xzf ' + get_localpath() + ' --directory ' + args.target)

if(args.type == FILE):
    print("Restoring file " + args.target)
    os.remove(args.target) if os.path.exists(args.target) else None
    shutil.copyfile(get_localpath(), args.target)

if(args.type == VOLUME):
    print("Restoring volume " + args.target)
    VOLUME_FOLDER = "/var/lib/docker/volumes/" + args.target
    runShellCommand("rm -r " + VOLUME_FOLDER)
    os.makedirs(VOLUME_FOLDER, exist_ok=True)
    runShellCommand('tar -xzf ' + get_localpath() + ' --directory ' + VOLUME_FOLDER)

print("Restore finished")
print("")





