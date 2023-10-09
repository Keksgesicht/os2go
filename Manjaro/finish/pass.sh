#!/bin/bash -e

if [ $(id -u) != 0 ]; then
	echo "please rerun as root!"
	exit 1
fi

keyfile='/etc/cryptsetup-keys.d/root.key'
dev_root=$(cryptsetup status root | awk '$1 ~ /^device:$/ {print $2}')

###               ###
#=# TO BE REMOVED #=#
###               ###
echo "systemd-cryptenroll update to date?!"
exit 0

if [ "$1" == "tpm2" ]; then
	secboot_status=$(bootctl status 2>/dev/null | awk -F':' '$1 ~ /Secure Boot/ {print $2}' | awk '{print $1}')
	if [ "$secboot_status" == "disabled" ]; then
		echo "secure boot not enabled!"
		echo "Aborting ..."
		exit 2
	fi

	# enroll key to TPM 2.0
	# cryptsetup luksAddKey --key-file=${keyfile} ${dev_root}
	systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+1+2+3+7 --tpm2-with-pin=true --unlock-key-file=${keyfile} ${dev_root}
	sed -i 's|'$keyfile'|-\ttpm2-device=auto|g' /etc/crypttab
else
	# on usb-stick installation add a manuell key
	cryptsetup luksAddKey ${dev_root} --key-file ${keyfile}
fi

# making old keyfile on inside initramfs useless
# the unencrypted EFI partition does not contain security related data
# new keyfile makes it possible to do changes
keyfile_new="${keyfile}.new"
dd if=/dev/urandom of=${keyfile_new} iflag=fullblock bs=512 count=4
cryptsetup luksAddKey ${dev_root} ${keyfile_new} --key-file ${keyfile}
cryptsetup luksRemoveKey ${dev_root} ${keyfile}
mv ${keyfile_new} ${keyfile}
sed -i 's|'$keyfile'||g' /etc/mkinitcpio.conf

# recreate initramfs and boot image without the keyfile
/etc/pacman.d/scripts/secure-boot-update

# create a recovery key
systemd-cryptenroll --recovery-key --unlock-key-file=${keyfile} ${dev_root}


# https://wiki.archlinux.org/title/Trusted_Platform_Module#Accessing_PCR_registers
# https://pawitp.medium.com/full-disk-encryption-on-arch-linux-backed-by-tpm-2-0-c0892cab9704
