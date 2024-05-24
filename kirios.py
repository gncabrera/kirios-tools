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

Kirios tools v1.4.8
https://kirios.co
"""

VERSION = "Kirios Tools v1.4.8"
BASE_FOLDER = '/opt/kirios'
SECRETS_FOLDER = '/opt/kirios-secrets'

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
LOGO = 'logo'
SERVER = 'server'

parser = argparse.ArgumentParser(description='Kirios Toolset Script (https://kirios.co)')
parser.add_argument('action', choices=[VOLUMERIZE, UPDATE, LS, INSTALL, UNINSTALL, RUN, RESTORE, CHECK_INSTALL, TOOL, NGINX, BACKUP, CHMOD, SECRETS, LOGO, SERVER], help = 'action to perform on the target. It relates to a previously defined script. For example for the script docker.install the action is "install"')
parser.add_argument('target', nargs='?', default = '', help = 'target of the specified action. This defines which "action" script will be executed. For example for the script docker.install the target is "docker"')
parser.add_argument('params', nargs='?', default = '', help = 'parameters to append to the action script')
parser.add_argument('--version', action='version', version = VERSION)
parser.add_argument('--force', action='store_true')
parser.add_argument('--verbose', '-v', action='store_true')

args = parser.parse_args()

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

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

def log(msg):
    if(args.verbose):
        print(msg)

def runShellCommandStrict(command):
    log(command)
    subprocess.check_call(command, shell = True)

def runShellCommand(command):
    log(command)
    return subprocess.call(command, shell = True)

def logo():    
    print(KIRIOS_LOGO)

def update():    
    print(f"{bcolors.OKCYAN}Checking new version...{bcolors.ENDC}")
    runShellCommand('git config --global credential.helper "cache --timeout=36000000"')
    runShellCommand('cd ' + BASE_FOLDER + ' && git checkout -- . && git pull')
    runShellCommand('chmod -R a+rw ' + BASE_FOLDER)
    print(f"{bcolors.OKCYAN}Looking for new secrets...{bcolors.ENDC}")
    runShellCommand('kirios secrets update')
    chmod()

def chmod():
    opts = " -type f -regex '.*\.\(cron\|install\|volumerize\|sh\|uninstall\|restore\|tool\|check-install\|py\|secrets\|nginx\|backup\|server\)' -exec chmod +x {} \;"
    runShellCommand("find -L " +  BASE_FOLDER + opts)
    runShellCommand("find -L " +  SECRETS_FOLDER + opts)


def get_all_scripts(query):
    result = [y for x in os.walk(BASE_FOLDER) for y in glob(os.path.join(x[0], query))]

    scripts = []
    for res in result:
        script = Script(res)
        scripts.append(script)

    

    if os.path.isdir(SECRETS_FOLDER):
        result = [y for x in os.walk(SECRETS_FOLDER) for y in glob(os.path.join(x[0], query))]
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
        print(f"{bcolors.FAIL}There is no {bcolors.BOLD}{extension}{bcolors.BOLD} script for {script}{bcolors.ENDC}")
        return
    script = files[0]
    executable = script.path + " " + parameters
    print(f"Executing {bcolors.OKGREEN}{executable}{bcolors.ENDC}")
    runShellCommand(executable)
    

def is_installed(script):
    files = get_all_scripts(script + "." + CHECK_INSTALL)
    if not files:
        print('Cannot check installation. Missing ' + script + '.' + CHECK_INSTALL)
        return False
    script = files[0]
    print(f"Executing {bcolors.OKGREEN}{script.path}{bcolors.ENDC}")
    return runShellCommand(script.path) == 0

def check_target():
    if not args.target:
        print('[target] not specified')
        exit(-1)

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

if (args.action == LOGO):
    logo()
    exit(0)

# By default tries to run the target.action [args.params]
check_target()
run_script(args.action, args.target, args.params)
exit(0)





