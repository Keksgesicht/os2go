#!/bin/bash

if [ $(id -u) != 0 ]; then
	echo "please rerun as root!"
	exit 1
fi
export dir_work="$(dirname $0)"

if ! rsync --list-only "$dir_backup"; then
	echo "$dir_backup failed!"
	echo 'export dir_backup=\"192.168.178.150::backup\"'
	echo 'export dir_backup=\"/mnt/backup\"'
	exit 2
fi
export dir_root="${dir_backup}/host"
export dir_home="${dir_backup}/homeBraunJan"

if ! [ -b "$disk_target" ]; then
	echo "\"$disk_target\" is not a block device!"
	echo 'show what "lsblk -f" gives you'
	echo 'export disk_target=/dev/sdX'
	exit 3
fi
export disk_target

PRESETS_FILE=${dir_work}/presets/presets.sh

myPreset=$1
presets=$(awk -F'(' '/^preset/ {print $1}' ${PRESETS_FILE})
if [ -z "$1" ] || ! echo "$presets" | grep -Eq '^'"${myPreset}"'$'; then
	echo "select a preset:"
	echo "$presets"
	exit 4
fi

source ${dir_work}/prepare/system.sh
source ${dir_work}/prepare/disk.sh
pushd ${dir_target}
chroot_umount
target_umount

time bash -ex ${PRESETS_FILE} ${myPreset}
code_error=$?

if [ 0 != $code_error ]; then
	echo "#-------------------------------------#"
	echo "| ABORT: non zero-exit code detected! |"
	echo "| code: $code_error                   |"
	echo "#-------------------------------------#"
	code_exit=255
else
	echo "#-----------------------------------#"
	echo "| os2go script finished successful! |"
	echo "#-----------------------------------#"
	code_exit=0
fi

source ${dir_work}/cleanup.sh
kill_open

exit $code_exit
