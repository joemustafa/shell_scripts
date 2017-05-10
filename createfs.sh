#!/bin/sh





for DEV in /sys/block/sd*
    do
        DEV=`basename $DEV`
        mkfs.ext4 -F -q /dev/${DEV}
    done