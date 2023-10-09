#!/bin/bash

for import in $(realpath ${dir_work}/prepare/*.sh); do
	source ${import}
done

group_disk() {
	export dir_root="${dir_backup}/host"

	part_gpt_efi
	if [ "$1" == "swap" ]; then
		part_root_with_swap
	else
		part_root
	fi
	crypt_root
	target_mount

	disk_efi=$(find -L /dev/disk/by-uuid -samefile $part_target_1 | awk -F'/' '{print $NF}')
	disk_root=$(find -L /dev/disk/by-uuid -samefile $part_target_2 | awk -F'/' '{print $NF}')
}

install_manjaro() {
	source ${dir_work}/packages/distro.sh
	manjaro

	copy_config
	fix_sddm
}

group_home() {
	#cfg_panel
	cfg_window_rules
	cfg_autostart
	cfg_audio
	cfg_energy
	mk_Trash
}

group_docs() {
	mk_docs
	mk_git
	copy_Office
	copy_background
}

group_system() {
	cfg_hosts

	fs_vm
	fs_root
	if [ "$1" == "swap" ]; then
		fs_swap
	fi

	sync_disk
	chroot_system
}

group_efi() {
	efi_keys
	if [ "$1" == "usb" ]; then
		efi_keys2disk
		sed -i '/efimgr.sh/d' ${dir_target}/etc/pacman.d/scripts/secure-boot-update
	else
		efi_updatevar
	fi
	memtest86
}
