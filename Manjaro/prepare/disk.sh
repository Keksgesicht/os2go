#!/bin/bash

dir_target='/tmp/mnt/target'

part_gpt_efi() {
	dd if=/dev/urandom of=${disk_target} status=progress bs=1M count=384
	partprobe $disk_target

	(
	echo g
	echo n
	echo 1
	echo 2048
	echo +256M
	echo t
	echo uefi
	echo w
	) | fdisk $disk_target
}

part_root() {
	(
	echo n
	echo 2
	echo
	echo
	echo w
	) | fdisk $disk_target || partprobe $disk_target
}

part_root_with_swap() {
	(
	echo n
	echo 2
	echo
	echo -24G
	echo n
	echo 3
	echo
	echo
	echo t
	echo 3
	echo swap
	echo w
	) | fdisk $disk_target || partprobe $disk_target
}

crypt_root() {
	part_target=$(fdisk -l $disk_target | grep "^$disk_target" | awk '{print $1}')
	part_target_1=$(echo "$part_target" | sed -n '1p')
	part_target_2=$(echo "$part_target" | sed -n '2p')

	mkfs.vfat -F32 -n EFI ${part_target_1}
	keyfile=$(mktemp)
	chmod 600 $keyfile
	dd if=/dev/urandom of=${keyfile} iflag=fullblock bs=512 count=4
	echo 'YES' | cryptsetup luksFormat $part_target_2 $keyfile --type luks2
}

target_mount() {
	cryptsetup open ${part_target_2} 'crypt_tmp_root' --key-file $keyfile
	mkfs.btrfs -K -L 'linux_root' '/dev/mapper/crypt_tmp_root'

	mkdir -p $dir_target
	mount '/dev/mapper/crypt_tmp_root' ${dir_target}
	mkdir -p ${dir_target}/boot/efi
	mount ${part_target_1} ${dir_target}/boot/efi
}

target_umount() {
	cd
	umount ${dir_target}/boot/efi
	umount ${dir_target}
	cryptsetup close 'crypt_tmp_root'
}
