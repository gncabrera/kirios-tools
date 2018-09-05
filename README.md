# kirios-tools
A set of tools to run all my applications


## Installation
```
wget -O kirios.install https://gitlab.com/gncabrera/kirios-tools/raw/master/kirios.install && chmod +x kirios.install && ./kirios.install
```

## Newly created Ubuntu Server 16.04 VM

- Create user ubuntu with standard password
```
sudo apt install ssh
ifconfig
```

- Add a static ip through pfSense (Status > DHCP Leases > Add static mapping) and reboot
- Login through jump host
```
sudo su
echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
wget -O kirios.install https://gitlab.com/gncabrera/kirios-tools/raw/master/kirios.install && chmod +x kirios.install
sudo ./kirios.install
```

## Tools
- Jump host
```
ssh -i /home/gcabrera/.ssh/de_aztec.pem -t ubuntu@de_aztec.kirios.co ssh ubuntu@192.168.1.13
```
- Delete all empty folders
```
find . -empty -type d -delete
```
## Installation DEV

```
cd /path/to/project
chmod +x kirios.install.dev && sudo ./kirios.install.dev
```

## TODO
- [ ] kirios docker run ubuntu
- [x] Generalize installation to make the repo public
- [ ] Add parameters to child script with "--". Like: kirios docker run -- -param1 "extra param1" -p2
- [ ] Add executable header to make it executable on update, not with extension like kirios.py > def update()
- [ ] docker prune bookstack-container -> Removes the container and all related volumes
- [ ] Add add-cron as user

