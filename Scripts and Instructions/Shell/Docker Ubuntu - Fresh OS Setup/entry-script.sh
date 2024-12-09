#!/bin/bash

user=artur
sudoers_f='/etc/sudoers';

apt-get -y update
#apt-get install apt-utils
#apt-get -y install software-properties-common
apt-get -y install vim sudo curl wget sed
adduser --disabled-password --gecos "" artur

if [ "$(sed -n /$user/p $sudoers_f | wc -l)" -eq '0' ]; then
		echo "$user ALL=(ALL) NOPASSWD: ALL" >> $sudoers_f
else
        echo "$u_id existing. Exiting ..";
        return 1;
fi

cp "/home/fresh-install.sh" "/home/$user/"
cd "/home/$user/"
chown artur fresh-install.sh
sudo -u $user ./fresh-install.sh # 2>&1 | sudo -u $user tee "/home/$user/installation-log.txt"
# redirection of install progress to logs in any way blocks postgres interactive installation
# It is probably not possible to install in a non interactive way postgres on this ubuntu image becasue of:
# https://stackoverflow.com/questions/59299133/how-to-silent-install-postgresql-in-ubuntu-via-dockerfile
# It would require to create custom docker file and build image with:
# FROM ubuntu:latest
# ARG DEBIAN_FRONTEND=noninteractive

su artur
