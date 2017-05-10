#!/bin/sh





for DEV in /sys/block/sd*
    do
        DEV=`basename $DEV`
        parted /dev/${DEV} print
    done
