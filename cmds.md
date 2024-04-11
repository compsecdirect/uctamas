# Using Containers to Analyze malware at Scale: UCTAMAS; from CompSec Direct

## This document has all workshop commands, and tasks. 
**Please note the other files in this repo as they can be used and modified to your needs.**  

# Workshop 1 - Docker refresh

## Common commands

### Show me all containers

```
docker container ls -a
```

### Show me all volumes
```
docker volume ls -a
```

### Show me all running containers
```
docker ps
```
### Show me all containers; stopped and running
```
docker ps -a
```
### Stop a container; example ID is 89347563 name is myContainer
```
docker stop ID or NAME 
```
#### TIP: ID is random number while NAME is defined  

`docker stop 89347563 ; docker stop myContainer`

### Show me all details about a container or image
```
docker inspect ID or NAME 
```

### Show me details on docker config on host; Get OS config related to docker deployment
```
docker info
```
### Create and Run a new container from an image
```
docker run
```
### Create a new container from the specified image, but dont start it 
```
docker create
```
### Run command on running container
```
docker exec
```

## Lab exersize #1 ; Pull down samples

- Task 1. Range check - Ensure you can login to the range.
- Task 2. `malware-daily.py` usage  

### Pulls previous day's samples from Malware Bazaar into myfolder;  
*myfolder gets created if non-existent*
 ```
 python3 malware-daily.py -p myfolder
 ```  
Note: This process can take up to 20 minutes; it really depends on how many samples malware-bazaar placed in the previous day's archive. 

### Query Malware Bazaar for a given md5/sha1/sha256/ value
```
python3 malware-daily.py -q myHashValue
```

- Task 3. Pull images / run / start and stop containers

```
docker pull python:3.7.15-alpine3.17
```

```
docker run -dit --name myalpine python:3.7.15-alpine3.17
```

```
docker stop myalpine
```

```
docker start myalpine
```

- Task 4. Mounts and volumes

```
docker run -dit --mount type=bind,source=/etc/shadow,target=/
myShadow alpine:latest
```

```
docker run -dit -v /etc/shadow:/myShadow alpine:latest
```


```
docker volume create myvolume
```

```
docker run -dit -v myvolume:/myvolume alpine:latest
```

```
docker run -dit --mount source=myvolume,target=/myvolume alpine:latest
```

- Task 5. Add files / tools to containers and volumes
```
docker volume create tools
```
```
docker volume create samples
```

```
docker run -dit --name yarGen -v tools:/tools -v samples:/samples python:3.7.15-alpine3.17
```

```
docker cp yarGen-master.zip yarGen:/tools
```

```
docker cp yarGen-master.zip yarGen:/opt/
```

```
docker exec -it yarGen sh
```

or

```
docker exec -it unzip /tools/yarGen-Master.zip
```

```
docker exec -it python3 /tools/yarGen-Master/yarGen.py --update
```

```
docker exec -it yarGen sh
```
or

```
docker info 
```
*Note: Look at docker Root Dir; defaults to `"/var/lib/docker"`*

#### Use native copy commands vs docker cp

```
cp YourTools /var/lib/docker/volumes/tools/_data/
```
 *TIP: Notice how this fails unless root/sudo, however, as part of the `docker group`; you can influence and `modify the contents` of this folder path as it is easier this way and still valid way when storage driver is default overlay2*

```
python3 yarGen.py --update
```

Bonus: 
```
docker exec -it yarGen python3 /tools/yarGen-Master/yarGen.py
```
### Question: why is this inefficient?

- Task 6. Commit / save base container with samples and tool volumes

```
docker commit -m "Some changes on this day" yarGen
 mylocalyargen:mar252023
 ```
### This pauses running containers creates new image

```
docker save mylocalyargen:mar252023 -o myexport.tar
```
### You can export an image with tar with someone else, move it to aonther filesystem

```
docker rmi mylocalyargen:mar252023
```
### remove the localrepo and tag we committed earlier

```
docker load -i myexport.tar
```
### "Import" the image has now been remade

- Task 7. Non-root user
*alpine base container*  

### Heredoc to generate a new Dockerfile as a non-root user

```
cat <<EOF>> Dockerfile
FROM mylocalyargen:mar252023
RUN addgroup -S user && adduser -S non-root -G user
user non-root
EOF
```

### Build the image with nonroot user already defined
```
docker build -t mylocalyargen:nonrootmar252023 .
```

### Run the image, and bypass the non-root user specified

```
docker run -dit --name yarGenNonroot -v tools:/tools -v samples:/samples --user root mylocalyargen:nonrootmar252023 
```

*Note: need to fix file permissions, access denied, path permission problems; let's chown stuff!!*  


```
docker exec -it yarGenNonroot chown -R non-root:user /tools /samples
```

```
docker exec -it yarGenNonroot sh
``` 
*Note: We are still root!!*
```
docker stop yarGenNonroot
```

```
docker rm yarGenNonroot
```

```
docker run -dit --name yarGenNonroot -v tools:/tools -v samples:/samples mylocalyargen:nonrootmar252023
```

```
docker exec -it yarGenNonroot whoami
```
*Note the non-root user, this user account is now "jailed".*  

**Now we have a limited user account that cannot benefit from root privileges inside container while still running tools**  


# Workshop 2 - Containers on Windows
*Container tools & commands*

We will create a windows volume and mount it using a non-existent folder.

`c:\tools` is a volume outside of container, mounted into the container.   
Called tools in volumes

*docker images for Microsoft are not on Dockerhub; use MCR instead*

```
docker pull mcr.microsoft.com/windows/servercore:ltsc2022
```
*Note the file size of images*  


- Task 1: create a volume

Volumes help store data out of containers. This helps store data in more "permanent" locations until the volume is removed.

```
docker volume create tools-volume
```

- Task 2: create container from image with volume  

Creating a container with create makes the data inside the container more "permanent" until the container is removed.    

```
docker create -t --name CoreTest -h CoreTest --mount source=tools-volume,target=c:\tools -i mcr.microsoft.com/windows/servercore:ltsc2022
```

- Task 3: run a single command  

Running a container with run is ephemeral and non-permanent.
```
docker run mcr.microsoft.com/windows/servercore:ltsc2022
```

- Task 4: detach from running container  
`Press Ctrl-P, followed by Ctrl-Q` **YMMV**

- Task 5: move new tools into container
```
docker cp C:\Users\Administrator\Downloads\capa-v5.0.0-windows.zip CONTAINERNAME:c:\tools
```
*Note: This Fails due to Administrator Path*

- Task 6: Download all the tools
```
docker cp C:\Users\Administrator\Downloads\7z2201-extra.7z CONTAINERNAME:c:\tools
```
*Note: This Fails due to Administrator Path; how can we pull tools down if permissions are a problem?*

### TIP: Use the get_tools.ps vs running these commands manually

### 7zr https://7-zip.org/a/7zr.exe
Invoke-WebRequest -Uri https://7-zip.org/a/7zr.exe -Method GET -UseBasicParsing -outfile c:\tools\7zr.exe

### Get CAPA https://github.com/mandiant/capa/releases/download/v5.0.0/capa-v5.0.0-windows.zip
Invoke-WebRequest -Uri https://github.com/mandiant/capa/releases/download/v5.0.0/capa-v5.0.0-windows.zip -Method GET -UseBasicParsing -outfile c:\tools\capa-v5.0.0-windows.zip

### Get 7z-extras https://7-zip.org/a/7z2201-extra.7z
Invoke-WebRequest -Uri https://7-zip.org/a/7z2201-extra.7z -Method GET -UseBasicParsing -outfile c:\tools\7z2201-extra.7z

### Use 7zr to extract 7z-extras; 7z-extras will allow you to extract password protected files from malware bazaar
.\7zr.exe e .\7z2201-extra.7z

### Extract CAPA
Expand-Archive -LiteralPath .\capa-v5.0.0-windows.zip -DestinationPath .

- Task 7: run an interactive terminal

```
docker exec -i ID or NAME cmd.exe
```

- Task 8: stop a container

```
docker stop ID or NAME
```

- Task 9: save container changes to new image
*Note: the ID will be different, repo tag could be different*
```
docker commit 80a0a3b54672 REPO/servercore:11nov22
```
- Task 10: export container  
```
docker save REPO/servercore:11nov22 -o 11nov22.tar
```

- Task 11: "Expert" mounted  

```  
docker run -dit --name python-non-admin -v scripts:c:\scripts -v samples:c:\samples -v workshop_tools:c:\tools -v output:c:\output -v python_311:c:\python\ uctamas:apr222023
```

# Workshop 3 - Scripted Malware analysis

This workshop represents what you can expect to see on the ransomware side of malware found on low-cost NAS devices. 
- The samples are 386 and arm based Go binaries. 
- You can develop an analysis workflow where you test static tools using an OS opposite to the binaries you are analyzing. *ex: analyze Windows binaries in GNU / Linux; and vice-versa.*
- You can also develop a similar workflow for CPU architectures all together. *ex: analyzing x86 binaries on arm; and vice-versa*  

When it comes to dynamic analysis; using the anticipated binary types, and architectures creates the possibility of virtualizing an environment to help contain some of these threats, and then using containers to execute the samples as many times as you need, within the same VM.

This workshop uses a virtual environment with containers.  

The samples do not function the same way since the C2 is no longer available.

The instance you launch has memory dumps, process/network dumps, stack traces, and other information that is no longer generated due to the missing c2.  

 Although you can run the tools, and remove older information; you should launch a new instance after you have experimented enough and are willing to spend some time looking at previously collected materials.

Ghidra, Binary Ninja, gdb are pre-installed. Ghidra has all the functions mapped from the 386 binary. 

*Binary Ninja requires activation by the user*

`cd ~/RANSOMWARE-Caution/ech0raix`  
> 1. follow Docker-instructions.txt inside home folder to launch container  
> 2. use output for special scripted tools to help automate analysis
Use `clean-all.sh` to remove older material  
*Note: Since sample is older, some artifacts wont be possible to recover*    
> 3. After launching the tools, you will quickly run out of inodes on the folders where data is being collected due to the high-polling rate of a simple while true loop.  
*Note: Observe the fractions of seconds of sampling performed.*  

Use `tmux-launch.sh` to quickly automate some analysis tools. You can comment things in and out to test some new ideas.   
*Note: Since this is looped we need to control execution time*  

`docker run --rm -it -v /home/kali/RANSOMWARE-Caution/ech0raix:/home/debian -w /home/debian/output ech0raix/jan302022am timeout 30s /home/debian/output/tmux-launch.sh`


## Workflow example; start to finish
Windows Workflow steps using Malware-Bazaar:

0. The hash value of a sample is passed to powershell variable. The value was read in using parallelism vs a for loop.   

1. pull samples by using powershell to make a post request
`$postParams = @{query='get_file';sha256_hash='094fd325049b8a9cf6d3e5ef2a6d4cc6a567d7d49c35f8bb8dd9e3c6acf3d78d'}

2. Invoke-WebRequest -Uri https://mb-api.abuse.ch/api/v1/ -Method POST -Body $postParams -UseBasicParsing -outfile c:\samples\094fd325049b8a9cf6d3e5ef2a6d4cc6a567d7d49c35f8bb8dd9e3c6acf3d78d.zip

3. decompress; powershell cannot extract 7z files with passwords due to missing compression algorithm; now scheduled for windows 11.  

*7z*    
```
c:\tools\7za x -pinfected c:\samples\094fd325049b8a9cf6d3e5ef2a6d4cc6a567d7d49c35f8bb8dd9e3c6acf3d78d.zip
```

4. run tool or tools, your local Windows AV will prevent some samples; **send only your strongest warriors that bypass defenses!** The disk and process deadlock is very noticeable.    

*capa*
```  
./capa.exe c:\samples\094fd325049b8a9cf6d3e5ef2a6d4cc6a567d7d49c35f8bb8dd9e3c6acf3d78d.exe
```
### This section needs some tweaks, and may not work at first.  

5. add tor  

```
docker pull alpine:latest
pull files from https://github.com/klemmchr/tor-alpine
run tor-alpine.sh
```

6. add mitm proxy  
```
docker pull mitmproxy/mitmproxy:latest
docker run --rm -it [-v ~/.mitmproxy:/home/mitmproxy/.mitmproxy] -p 8080:8080 mitmproxy/mitmproxy
```

7. Use socks5/http proxy compatible services over proxy configs. Since these are on the same host, localhost should be ok.    
*Source: https://stackoverflow.com/questions/61590317/use-socks5-proxy-from-host-for-docker-build*  

For tor:  
Create or edit the /etc/systemd/system/docker.service.d/proxy.conf file and add:
```
[Service]
Environment="HTTP_PROXY=socks5://127.0.0.1:<PROXY_PORT>"
Environment="HTTPS_PROXY=socks5://127.0.0.1:<PROXY_PORT>"
```
For mitm proxy; https needs a ca to be installed:  
```
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:<PROXY_PORT>"
Environment="HTTPS_PROXY=https://127.0.0.1:<PROXY_PORT>"
```

Replace <PROXY_PORT> with your proxy port. Then, reload systemd and restart Docker:

`sudo systemctl daemon-reload`  
`sudo systemctl restart docker docker.service`

Test both ports `9050` and the `8080`

8. save output to volume

9. ingest into searchable
