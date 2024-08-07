#!/bin/bash
TZ=Americas/New_York date
TDATE=$(date +%m.%d.%Y.%H.%M.%s.%N)
watchme() {

TDATE=$(date +%m.%d.%Y.%H.%M.%s.%N)
ps -efw | tee ps-save."$TDATE"
netstat -panut | tee ns-save-"$TDATE"
}

while true
do
        watchme
done
