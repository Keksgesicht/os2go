#!/bin/bash

source ${dir_work}/vars.sh
source ${dir_work}/presets/func-groups.sh
export OLD_HOSTNAME='cookieclicker'

preset_laptop() {
    export SET_HOSTNAME='cookiethinker'
    export SET_AUTOSTART='pkgdump.sh|copyq|nextcloud'

	group_disk 'swap'
	install_manjaro

	group_home
	group_docs
	copy_Studium

	chroot_mount
	group_system 'swap'
	group_efi
}

preset_usb() {
	export SET_HOSTNAME='cookie-usb'
	export SET_AUTOSTART='pkgdump.sh|copyq'

	group_disk
	install_manjaro

	group_home
	group_docs

	chroot_mount
	group_system
	group_efi 'usb'
}

$1

echo ""
echo "@@@ END OF EXECUTION @@@"
echo ""
