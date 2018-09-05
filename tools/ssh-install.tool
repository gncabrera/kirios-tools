#!/bin/bash

# DESCRIPTION: adds a cron. Usage: add-cron my-app "* * * * * echo hello"
# DEPENDENCIES: none

SSHUSER=$1
PUBLIC_KEY=$2

if [[ $# -lt 2 ]] ; then
    echo 'Must specify user and public key file. Usage: ssh-install myuser /path/to/key/mykey.pub'
    exit 1
fi

mkdir -p /home/$SSHUSER/.ssh && chmod 700 /home/$SSHUSER/.ssh
cat $PUBLIC_KEY >> /home/$SSHUSER/.ssh/authorized_keys
chown -R $SSHUSER:$SSHUSER /home/$SSHUSER/.ssh
echo "$SSHUSER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
apt install ssh -y
ufw allow 22