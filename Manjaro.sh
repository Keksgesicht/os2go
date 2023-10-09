#!/bin/bash

work_dir=$(dirname $0)
source ${work_dir}/os2go/vars.sh

rsync ${RSYNC_FLAGS} -v --delete ${remote_ip}::os2go/ ${work_dir}/os2go/

cd ${work_dir}/os2go
exec ./main.sh $@
