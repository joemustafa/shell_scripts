#!/bin/sh


hdd="/dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg /dev/sdh /dev/sdi /dev/sdj /dev/sdk /dev/sdl /dev/sdm /dev/sdn /dev/sdo"

for i in $hdd; do
echo "$i"

for var in 1 2 3 4 5 6 7 8 9
do
   parted $i rm $var
done

done
