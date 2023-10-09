#!/bin/bash

manjaro() {
	chroot_mount

	source ${dir_work}/packages/pacman/pkg.sh
	pkg_install 'basic'

	chroot_umount
}
