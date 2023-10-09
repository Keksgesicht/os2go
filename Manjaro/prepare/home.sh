#!/bin/bash

# Panels to Laptop Screen
cfg_panel() {
	sed -i 's/^lastScreen=[0-9]*$/lastScreen=0/g' ${dir_target}/home/keks/.config/plasma-org.kde.plasma.desktop-appletsrc
}

# delete KDE window rules
cfg_window_rules() {
	sed -i 's|^count=.*$|count=4|'												${dir_target}/home/keks/.config/kwinrulesrc
	sed -i 's|^rules=.*$|rules=8,9,10,02e4fcd6-c32d-4ab0-bb4b-09ff5daa919c|'	${dir_target}/home/keks/.config/kwinrulesrc
}

# remove unessary autostart
cfg_autostart() {
	rm -v $(realpath ${dir_target}/home/keks/.config/autostart/* | grep -Ev "${SET_AUTOSTART}")
}

cfg_audio() {
	sed -i 's|^#=#||g'		${dir_target}/home/keks/.local/bin/audio/init-audio.sh
	sed -i '/ferdium/,+1d'	${dir_target}/home/keks/.local/bin/audio/init-audio.sh
#	rm						${dir_target}/home/keks/.local/bin/audio/vban-gaming.sh
}

# AC Power (Energy Saving)
cfg_energy() {
	sed -i 's/^Timeout=[0-9]*$/Timeout=3/'			${dir_target}/home/keks/.config/kscreenlockerrc

	### https://forum.manjaro.org/t/howto-disable-turn-off-hibernate-completely/8033
	mkdir -p /etc/systemd/sleep.conf.d
	cat << 'EOF' > /etc/systemd/sleep.conf.d/no-hibernate.conf
[Sleep]
# disable hibernation
AllowHibernation=no
AllowHybridSleep=no
AllowSuspendThenHibernate=no
EOF
	mkdir -p /etc/systemd/logind.conf.d
	cat << 'EOF' > /etc/systemd/logind.conf.d/no-hibernate.conf
[Login]
# disable hibernation
HibernateKeyIgnoreInhibited=no
EOF
}


### setup workspace

mk_docs() {
	mkdir ${dir_target}/mnt/array/homeBraunJan
	mkdir ${dir_target}/mnt/array/homeBraunJan/Documents
	mkdir ${dir_target}/mnt/array/homeBraunJan/Downloads
	mkdir ${dir_target}/mnt/array/homeBraunJan/Music
	mkdir ${dir_target}/mnt/array/homeBraunJan/Pictures
	mkdir ${dir_target}/mnt/array/homeBraunJan/Videos

	chown 1000:1000 -R ${dir_target}/mnt/array/homeBraunJan
}

mk_git() {
	mkdir -p ${dir_target}/mnt/array/homeBraunJan/Documents/development/git
	chown -R 1000:1000 ${dir_target}/mnt/array/homeBraunJan/Documents/development
	rsync ${RSYNC_FLAGS} ${dir_home}/Documents/development/git/bash_collection/	${dir_target}/mnt/array/homeBraunJan/Documents/development/git/bash_collection/

	ln -s /mnt/array/homeBraunJan/Documents/development/git	${dir_target}/mnt/array/homeBraunJan/git
	ln -s /mnt/array/homeBraunJan/Documents/development		${dir_target}/mnt/array/homeBraunJan/devel

	rsync ${RSYNC_FLAGS} ${dir_home}/Documents/development/containers/ ${dir_target}/mnt/array/homeBraunJan/Documents/development/containers/
}

copy_Office() {
	rsync ${RSYNC_FLAGS} ${dir_home}/Documents/BackUp/		${dir_target}/mnt/array/homeBraunJan/Documents/BackUp/
	rsync ${RSYNC_FLAGS} ${dir_home}/Documents/Office/		${dir_target}/mnt/array/homeBraunJan/Documents/Office/
	rsync ${RSYNC_FLAGS} ${dir_home}/Music/Alarms/			${dir_target}/mnt/array/homeBraunJan/Music/Alarms/
}

copy_background() {
	mkdir -p ${dir_target}/mnt/array/homeBraunJan/Pictures/Screenshots
	mkdir -p ${dir_target}/mnt/array/homeBraunJan/Pictures/background
	chown -R 1000:1000 ${dir_target}/mnt/array/homeBraunJan/Pictures
	rsync ${RSYNC_FLAGS} ${dir_home}/Pictures/background/	${dir_target}/mnt/array/homeBraunJan/Pictures/background/
}

copy_Studium() {
	mkdir -p ${dir_target}/mnt/array/homeBraunJan/Documents/development/git/Studium
	rsync ${RSYNC_FLAGS} 															${dir_home}/Documents/Studium/					${dir_target}/mnt/array/homeBraunJan/Documents/Studium/
	rsync ${RSYNC_FLAGS} --include-from="${dir_work}/prepare/git-studium.pattern"	${dir_home}/Documents/development/git/Studium/	${dir_target}/mnt/array/homeBraunJan/Documents/development/git/Studium/
}
