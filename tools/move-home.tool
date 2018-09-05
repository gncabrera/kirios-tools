#!/bin/bash
UUID=$1

blkid

if [[ $# -eq 0 ]] ; then
    echo 'Must specify partition UUID running: sudo blkid'
    exit 1
fi


echo "UUID=$UUID   /media/home    ext4          nodev,nosuid       0       2" >> /etc/fstab

mkdir /media/home
mount -a
rsync -aXS /home/. /media/home/.
cd /
sudo mv /home /home_backup
sudo mkdir /home
sed -i 's/\/media\/home/\/home/g' /etc/fstab
mount -a
rm -rf /home_backup

df -h