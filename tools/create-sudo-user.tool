#!/bin/bash

USER_NAME=$1

if [[ $# -eq 0 ]] ; then
    echo 'Must specify USERNAME'
    exit 1
fi

mkdir -p /home/$USER_NAME/.ssh
touch /home/$USER_NAME/.ssh/authorized_keys
useradd -d /home/$USER_NAME $USER_NAME
usermod -aG sudo $USER_NAME
chmod 700 /home/$USER_NAME/.ssh
chmod 644 /home/$USER_NAME/.ssh/authorized_keys
chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/
echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers