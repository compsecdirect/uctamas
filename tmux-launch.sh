#!/bin/bash
tmux new-session -s "malware" -d "/bin/bash /home/debian/output/ps-out.sh"
tmux rename-window -t 0 'malware'
tmux split-window -v -P -F "#{pane_id}"
#tmux send-keys "/bin/bash tor.sh" C-m
tmux send-keys "/usr/sbin/tcpdump -i eth0 -vv -w malware.pcap" C-m
tmux rename-window -t "malware:1" 'PCAP'
tmux split-window -h 
#tmux send-keys "strace -o /home/debian/output/strace-save.txt /home/debian/386 -s /share > /home/debian/output/strace-console.txt" C-m
tmux send-keys "gdb -ex=r --args /home/debian/386 -s /share| tee gdb-output.txt" C-m
tmux rename-window -t "malware:2" 'Debug'
#tmux select-pane -t 1
#tmux send-keys "gdb attach `cat /tmp/386.pid`" C-m
#tmux select-pane -t 2
#tmux send-keys -t "Nyx" "/bin/bash nyx.sh"
tmux -2 attach-session -d