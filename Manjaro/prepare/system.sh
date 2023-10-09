#!/bin/bash

# copy all system data
copy_system() {
	rsync ${RSYNC_FLAGS} --delete --include-from="${dir_work}/rsync.pattern" ${dir_root}/ ${dir_target}/
}

copy_config() {
	mkdir -p ${dir_target}/var/mnt
	rm -f ${dir_target}/mnt
	ln -sr ${dir_target}/var/mnt ${dir_target}/mnt

	rsync ${RSYNC_FLAGS} --include-from="${dir_work}/packages/host.pattern"			${dir_backup}/root/			${dir_target}/
	rsync ${RSYNC_FLAGS} --include-from="${dir_work}/packages/host-boot.pattern"	${dir_backup}/host-boot/	${dir_target}/boot/
	rsync ${RSYNC_FLAGS} --include-from="${dir_work}/packages/host-etc.pattern"		${dir_backup}/host-etc/		${dir_target}/etc/
	rsync ${RSYNC_FLAGS} --include-from="${dir_work}/packages/host-mnt.pattern"		${dir_backup}/host-mnt/		${dir_target}/mnt/
	rsync ${RSYNC_FLAGS} --include-from="${dir_work}/packages/host-home.pattern"	${dir_backup}/home/			${dir_target}/home/
	rsync ${RSYNC_FLAGS} --include-from="${dir_work}/packages/host-root.pattern"	${dir_backup}/var/roothome/	${dir_target}/root/

	mv	${dir_target}/etc/group.laptop		${dir_target}/etc/group
	mv	${dir_target}/etc/gshadow.laptop	${dir_target}/etc/gshadow
	mv	${dir_target}/etc/passwd.laptop		${dir_target}/etc/passwd
	mv	${dir_target}/etc/shadow.laptop		${dir_target}/etc/shadow
}

# fix hosts resolution
cfg_hosts() {
	sed -i 's|'${OLD_HOSTNAME}'|'${SET_HOSTNAME}'|g'	${dir_target}/etc/hostname
	sed -i 's|'${OLD_HOSTNAME}'|'${SET_HOSTNAME}'|g'	${dir_target}/etc/hosts
	sed -i '/192.168.178.150/d'							${dir_target}/etc/hosts
}

# enable autologin
cfg_autologin() {
	sed -i 's|^Session=|Session=plasma|'	${dir_target}/etc/sddm.conf.d/kde_settings.conf
	sed -i 's|^User=|User=keks|'			${dir_target}/etc/sddm.conf.d/kde_settings.conf
}

# sddm .config not writeable
fix_sddm() {
	chown -R sddm:sddm ${dir_target}/var/lib/sddm
}

### configure partition IDs

fs_vm() {
	mv	${dir_target}/etc/fstab.laptop	${dir_target}/etc/fstab
	sed -i 's|AAAA-AAAA|'${disk_efi}'|g'	${dir_target}/etc/fstab

	mv ${dir_target}/etc/mkinitcpio.conf.laptop ${dir_target}/etc/mkinitcpio.conf

	mkdir -m 700 ${dir_target}/etc/cryptsetup-keys.d
	cp $keyfile ${dir_target}/etc/cryptsetup-keys.d/root.key
	cp $keyfile ${dir_work}/luks-${disk_root}.key
}

fs_root() {
	mv	${dir_target}/etc/cmdline.laptop	${dir_target}/etc/cmdline
	mv	${dir_target}/etc/crypttab.laptop	${dir_target}/etc/crypttab
	sed -i 's|AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA|'${disk_root}'|g'	${dir_target}/etc/crypttab
	sed -i 's|AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA|'${disk_root}'|g'	${dir_target}/etc/cmdline
	sed -i 's|^\#/dev/mapper/root|/dev/mapper/root|g'					${dir_target}/etc/fstab
}

fs_swap() {
	part_target_3=$(echo "$part_target" | sed -n '3p')
	disk_swap=$(find -L /dev/disk/by-id -samefile $part_target_3 | awk -F'/' '$NF ~ /^(wwn-|nvme-eui).*-part3$/ {print $NF}')

	sed -i 's|/dev/disk/by-id/|/dev/disk/by-id/'${disk_swap}'|g'	${dir_target}/etc/crypttab
	sed -i 's|\#swap|swap|g'										${dir_target}/etc/crypttab
	sed -i 's|\#/dev/mapper/swap|/dev/mapper/swap|g'				${dir_target}/etc/fstab
}


### Driver and Boot setup

chroot_mount() {
	pushd $dir_target

	[ -d dev/ ] || mkdir dev/
	mount -t devtmpfs /dev dev/

	[ -d proc/ ] || mkdir proc/
	mount -t proc /proc proc/

	[ -d sys/ ] || mkdir sys/
	mount -t sysfs /sys sys/

	mountpoint /sys/firmware/efi/efivars || \
		mount -t efivarfs efivarfs /sys/firmware/efi/efivars
	mount -t efivarfs efivarfs sys/firmware/efi/efivars
}

chroot_umount() {
	umount sys/firmware/efi/efivars
	umount sys/
	umount proc/
	umount -l dev/
	popd
}

chroot_system() {
	chroot . systemctl disable \
		sddm.service

	chroot . systemctl enable \
		avahi-daemon.service \
		avahi-daemon.socket \
		bluetooth.service \
		cups.socket \
		firewalld.service \
		ModemManager.service \
		NetworkManager.service \
		NetworkManager-wait-online.service \
		sddm-plymouth.service \
		smartd.service \
		systemd-timesyncd.service

	sed -i 's|^\#SystemMaxUse=.*$|SystemMaxUse=512M|'	${dir_target}/etc/systemd/journald.conf
	sed -i 's|^\#SystemMaxFiles=.*$|SystemMaxFiles=64|'	${dir_target}/etc/systemd/journald.conf
}

sync_disk() {
	sync -f ${dir_target}
	sleep 5s
}
