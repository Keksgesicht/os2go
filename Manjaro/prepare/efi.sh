#!/bin/bash

### secure boot

efi_keys() {
  chroot ${dir_target} bash -c '
	efiname="$(cat /etc/hostname)"
	mkdir -m 700 /etc/efi-keys
	cd /etc/efi-keys
	echo ${efiname} | /etc/unCookie/helper/secure-boot/sbmkkeys.sh
	chmod 600 /etc/efi-keys/*
	/etc/unCookie/helper/secure-boot/make-image.sh ${efiname}
  '
}

efi_keys2disk() {
  chroot ${dir_target} bash -c '
	cd /etc/efi-keys
	cp *.auth /boot/efi/keys/
	cp *.esl /boot/efi/keys/
	cp *.cer /boot/efi/keys/
  '
}

efi_updatevar() {
  chroot ${dir_target} bash -c '
	efiname="$(cat /etc/hostname)"
	cd /etc/efi-keys
	efi-updatevar -e -f DB.esl db
	efi-updatevar -e -f KEK.esl KEK
	efi-updatevar -f PK.auth PK
	/etc/unCookie/helper/secure-boot/efimgr.sh ${efiname} "renew"
  '
}

memtest86() {
  chroot ${dir_target} bash -c '
	memtest_efi_file="/boot/efi/EFI/memtest86/memtest86.efi"
	cp /usr/share/memtest86-efi/bootx64.efi $memtest_efi_file
	/usr/bin/sbsign --key '/etc/efi-keys/DB.key' --cert '/etc/efi-keys/DB.crt' $memtest_efi_file
  '
}
