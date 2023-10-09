#!/bin/bash

remote_ip="${remote_ip:-192.168.178.150}"
export dir_backup="${remote_ip}::backup"

RSYNC_FLAGS='-azHA'
