#!/bin/bash

source ${HOME}/.local/bin/os2go/vars.sh
work_dir=$(dirname $0)
source_dir=${dir_backup}/host-home/${USER}/.var/app

copy_appdata() {
	app=$1
	if [ -z "${app}" ]; then
		echo "no app defined"
		return 1
	fi
	rsync ${RSYNC_FLAGS} --delete --delete-excluded \
		--include-from=${work_dir}/appdata.pattern  \
		${source_dir}/${app}/ \
		${HOME}/.var/app/${app}/
}

copy_predefined_list() {
	for app in $(cat ${work_dir}/apps.list); do
		copy_appdata ${app}
	done
}

case $1 in
	copy)
		copy_appdata $2
	;;
	help)
		echo "ToDo"
	;;
	list)
		rsync --list-only ${source_dir}
	;;
	*)
		copy_predefined_list
	;;
esac
