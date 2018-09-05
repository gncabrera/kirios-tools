#!/usr/bin/env python3
# Kirios Toolset Script (Python 3)
# https://kirios.co

import argparse
import subprocess
import os
import json
import socket
import time
import re
from glob import glob
from itertools import islice

KIRIOS_LOGO = """ 

 _    _      _           
| | _(_)_ __(_) ___  ___ 
| |/ / | '__| |/ _ \/ __|
|   <| | |  | | (_) \__ \\
|_|\_\_|_|  |_|\___/|___/

Kirios tools v1.0.0
https://kirios.co
"""

VERSION = "Kirios Tools v1.0.0"
BASE_FOLDER = '/opt/kirios'

UPDATE = 'update'
INSTALL = 'install'
CHECK_INSTALL = 'check-install'
RESTORE = 'restore'
UNINSTALL = 'uninstall'
TOOL = 'tool'
RUN = 'run'
LS = 'ls'
NGINX = 'nginx'
BACKUP = 'backup'
CHMOD = 'chmod'
SECRETS = 'secrets'
VOLUMERIZE = 'volumerize'


parser = argparse.ArgumentParser(description='Kirios Toolset Script (https://kirios.co)')
parser.add_argument('action', choices=[VOLUMERIZE, UPDATE, LS, INSTALL, UNINSTALL, RUN, RESTORE, CHECK_INSTALL, TOOL, NGINX, BACKUP, CHMOD, SECRETS], help = 'action to perform on the target. It relates to a previously defined script. For example for the script docker.install the action is "install"')
parser.add_argument('target', nargs='?', default = '', help = 'target of the specified action. This defines which "action" script will be executed. For example for the script docker.install the target is "docker"')
parser.add_argument('params', nargs='?', default = '', help = 'parameters to append to the action script')
parser.add_argument('--version', action='version', version = VERSION)
parser.add_argument('--force', action='store_true')
parser.add_argument('--verbose', '-v', action='store_true')

args = parser.parse_args()

class Script:
    def __init__(self, file):
        self.description = "No description"
        self.dependencies = []

        self.path = file
        self.basename = os.path.basename(file)
        splitted_basename = os.path.splitext(self.basename)
        size = len(splitted_basename)

        if(size > 0):
            self.name = splitted_basename[0]
        if(size > 1):
            self.extension = splitted_basename[1]


        with open(file) as myfile:
            head = list(islice(myfile, 10))
        
        for line in head:
            line = line.rstrip()
            line = line.replace("#", "")
            if ("DESCRIPTION:" in line):
                self.description = line.replace("DESCRIPTION:", "").strip()
            if ("DEPENDENCIES:" in line):
                result = line.replace("DEPENDENCIES:", "")
                for dep in result.split(","):
                    self.dependencies.append(dep.strip())

def checkRequirements():
    # Check That Running Under Sudo
    if (os.geteuid() != 0):
        print('Please run this script as root user')
        exit(-1)

def log(msg):
    if(args.verbose):
        print(msg)

def runShellCommandStrict(command):
    log(command)
    subprocess.check_call(command, shell = True)

def runShellCommand(command):
    log(command)
    return subprocess.call(command, shell = True)

def update():    
    runShellCommand('git config --global credential.helper "cache --timeout=36000000"')
    runShellCommand('cd ' + BASE_FOLDER + ' && git checkout -- . && git pull')
    runShellCommand('sudo chmod -R a+rw ' + BASE_FOLDER)
    chmod()

def chmod():
    runShellCommand("find -L " +  BASE_FOLDER + " -type f -regex '.*\.\(cron\|install\|volumerize\|sh\|uninstall\|restore\|tool\|check-install\|py\|secrets\|nginx\|backup\)' -exec chmod +x {} \;")


def get_all_scripts(query):
    result = [y for x in os.walk(BASE_FOLDER) for y in glob(os.path.join(x[0], query))]

    scripts = []
    for res in result:
        script = Script(res)
        scripts.append(script)

    return scripts

def ls(extension):
    files = get_all_scripts('*.' + extension)

    if not files:
        print('There are no "' + extension + '" scripts\n')
        return

    print('Existing "' + extension + '" scripts: \n')
    for file in files:
        print('\t-> ' + file.name + '\t' + file.description + ". Dependencies: " + ", ".join(file.dependencies))
    print('\nRun them with "kirios ' + extension + ' <script>"\n')

def run_script(extension, script, parameters):
    files = get_all_scripts(script + "." + extension)
    if not files:
        print('There is no ' + extension + ' script for ' + script + '\n')
        return
    script = files[0]
    executable = script.path + " " + parameters
    print('Executing ' + executable)
    runShellCommand(executable)
    

def is_installed(script):
    files = get_all_scripts(script + "." + CHECK_INSTALL)
    if not files:
        print('Cannot check installation. Missing ' + script + '.' + CHECK_INSTALL)
        return False
    script = files[0]
    print('Executing ' + script.path + '...')
    return runShellCommand(script.path) == 0

def check_target():
    if not args.target:
        print('[target] not specified')
        exit(-1)

#print(KIRIOS_LOGO)
checkRequirements()

if (args.action == UPDATE):
    update()
    exit(0)

if (args.action == LS):
    check_target()
    ls(args.target)
    exit(0)

if(args.action == CHMOD):
    chmod()
    exit(0)

if (args.action == INSTALL):
    check_target()
    if(not args.force and is_installed(args.target)):
        print("Skipping install...")
    else:    
        run_script(INSTALL, args.target, args.params)
    exit(0)


# By default tries to run the target.action [args.params]
check_target()
run_script(args.action, args.target, args.params)
exit(0)





