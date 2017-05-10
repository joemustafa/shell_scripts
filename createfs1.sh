#!/bin/sh


hdd="/dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg /dev/sdh /dev/sdi /dev/sdj /dev/sdk /dev/sdl /dev/sdm /dev/sdn /dev/sdo"

for i in $hdd; do
echo "n
p
1

+2G
n
p
2

+2G
n
p
3

+20G
n
p
4

+5G


w
" | fdisk $i 
done
