#!/bin/sh


hdd="/dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg /dev/sdh /dev/sdi /dev/sdj /dev/sdk /dev/sdl /dev/sdm /dev/sdn /dev/sdo"

for i in $hdd; do
echo "$i"
#parted $i rm 1
mkfs.ext4 -F -q $i

done
