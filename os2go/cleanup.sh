#!/bin/bash

kill_open() {
	for pid in $(ls /proc | grep -E '[0-9]'); do
		tofc=$(realpath $(find /proc/${pid} 2>/dev/null) 2>/dev/null | grep "${dir_target}" | wc -l)
		if [ 0 -lt ${tofc} ]; then
			echo ""
			echo "${pid}"
			realpath /proc/${pid}/exe
			realpath /proc/${pid}/cmd
			realpath /proc/${pid}/root
		fi
	done
}
