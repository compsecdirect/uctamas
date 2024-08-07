#!/bin/bash
tcpdump -i eth0 -w /home/debian/ech0raix.pcap
strace ./386 -s /share | tee output/strace-save.txt
./ps-out.sh