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
import shutil

VERSION = '1.0.0'
VOLUME = 'volume'
FOLDER = 'folder'
FILE = 'file'
TIMESTAMP = 'timestamp'

parser = argparse.ArgumentParser(description='Backup tool(https://kirios.co)')
parser.add_argument('application', help = 'name of the application to backup. Will be used to generate folders and other metadata.')
parser.add_argument('type', choices=[VOLUME, FOLDER, FILE], help = 'type of data that will be backed up')
parser.add_argument('target', help='target that will be backed up (folder, Docker container, etc.)')
parser.add_argument('--version', action='version', version = VERSION)
parser.add_argument('--filename', default = '', help = 'final name of the backup file. By default is {volume|folder}_YYYYMMdd_HHmmss.zip')
parser.add_argument('--folder', default = '', help = 'folder where the backup will be stored. By default is /{application}/')
parser.add_argument('--timestamp', default = '', help = 'timestamp for the filename. By default is YYYYMMdd_HHmmss')

args = parser.parse_args()

def runShellCommand(command):
    print('Executing - ' + command)
    return subprocess.call(command, shell = True)

def get_basefilename():
    return args.filename if args.filename else os.path.basename(args.target)

def get_timestamp():
    return args.timestamp if args.timestamp else now.strftime('%Y%m%d_%H%M%S')

def get_filename():
    return filename

def get_remotefolder():
    foldername = args.folder if args.folder else args.application
    return 'backup:' + foldername + "/" + get_basefilename()

def get_remotepath():
    return get_remotefolder() + '/' + get_filename()

def get_localfolder():
    return '/tmp'

def get_localpath():
    # TODO: Check get_filename() != ""
    return get_localfolder() + '/' + get_filename()
     
def print_overview():
    print('')
    print('Starting backup for the application ' + args.application + ': ' + args.type + ' ' + args.target)
    print('The output will be stored in ' + get_remotepath())
    print('')


now = datetime.datetime.now()
filename = get_basefilename()
filename = filename + '_' + get_timestamp() + '.tar.gz'

print_overview()



if(args.type == FOLDER):
    # create a zip of the folder in name temp_filename
    #to extract: sudo tar -xvzf /tmp/may_arch.tar.gz --directory /opt/kirios2
    print("Generating tar file: " + get_localpath())
    runShellCommand('env GZIP=-9 tar -czf "' + get_localpath() + '" --directory "' + args.target +'" .')

if(args.type == FILE):
    print("Generating file: " + get_localpath())
    shutil.copyfile(args.target, get_localpath())

if(args.type == VOLUME):
    VOLUME_FOLDER = "/var/lib/docker/volumes/" + args.target
    print("Generating tar file: " + get_localpath() + " from volume folder " + VOLUME_FOLDER)
    runShellCommand('env GZIP=-9 tar -czf ' + get_localpath() + ' --directory ' + VOLUME_FOLDER +' .')

print("Uploading file to " + get_remotepath())
runShellCommand('rclone move ' + get_localpath() +' '+ get_remotefolder() + ' -v --config=/opt/kirios/applications/rclone/rclone.conf')

print("Backup finished")
print("")


