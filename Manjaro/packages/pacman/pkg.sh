#!/bin/bash

PKG_CONF_DIR=${dir_work}/packages/pacman

pkg_install() {
	mkdir -p ${dir_target}/var/lib/pacman
	pacman -Sy -r ${dir_target}

	pkg_list=$(cat ${PKG_CONF_DIR}/${1}.list | tr '\n' ' ')
	pacman -S -r ${dir_target} --noconfirm $(echo $pkg_list)
}
