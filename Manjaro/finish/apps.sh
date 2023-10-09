#!/bin/bash

if [ $(id -u) != 0 ]; then
	echo "please rerun as root!"
	exit 1
fi

work_dir="$(dirname $0)"

#=# pacman
pacman-mirrors -c germany

pacman-key --init
pacman-key --populate
pacman-key --refresh-keys

#=# AUR
#sed -i	's|\#EnableAUR|EnableAUR|g'				/etc/pamac.conf
#sed -i	's|\#CheckAURUpdates|CheckAURUpdates|g'	/etc/pamac.conf

#pamac build --no-confirm \
#	opendoas-sudo

#=# flatpak
if ! grep -q EnableFlatpak /etc/pamac.conf; then
	echo 'EnableFlatpak' >> /etc/pamac.conf
fi

flatpak install --noninteractive \
	com.github.tchx84.Flatseal \
	org.gnome.Calculator \
	org.keepassxc.KeePassXC

for app in $(cat ${work_dir}/apps.list); do
	flatpak install --noninteractive ${app}
done
