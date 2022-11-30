#!/bin/bash

echo 'Ok, start me up'
#TODO: Make distributed test
#TODO: Make distributed test on AWS
#TODO: Make pooling function
#TODO: Make Database dump/clean/purge
#TODO: Make pdf reports
#TODO: esxi snapshop/restore loops
#TODO: Extract CWE and CVE from db


function sampleList() {
 find /home/jfer/samples/ -type f > list.txt
 echo "Currently in queue $(head -1 list.txt) "
 echo "Number in queue $(cat list.txt| wc -l) "
}

function moveFile() {
  echo "Moving a file $(head -1 list.txt)"
  mv $(head -1 list.txt) processed/
}

function sendSample() {
  echo "Submitting a file $(head -1 list.txt)"
  ./submiter.sh $(head -1 list.txt)
}

function healthCheck() {
  #In here, we pool the status codes of the nodes to ensure we can submit samples and not crash system

  #SourcedFrom: http://www.liamdelahunty.com/tips/linux_load_average_check.php // Pierre Forget
  loadavg=`uptime | awk '{print $10+0}'`

  thisloadavg=`echo $loadavg|awk -F \. '{print $1}'`
  if [ "$thisloadavg" -ge "2" ]; then
   return 1
  else
   return 0
fi
}

function analysisJobs(){
  analysis=$(curl http://localhost:5000/rest/status -X GET | jq .system_status[].analysis)
}

if sampleList; then
  if healthCheck; then
    if sendSample; then
      if moveFile; then
        echo "Moved File"
      else
        echo "Nothing to move or error"
      fi
    else
      echo "Nothing to submit or error"
    fi
  else
    echo "Not ready yet"
  fi
else
  echo "no more"
fi