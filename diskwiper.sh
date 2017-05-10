#!/bin/bash
VERSION_NUM_MAJ="1"
VERSION_NUM_MIN="2"
RELEASE_STATUS="PROD"
CREATED_BY="Joe Mustafa (jmustafa)"

# Default Flags for the DiskWiper
OS_DRIVE="sda sdb sdc"   #This is usually the Drive the OS is installed on


VFLAG=""                #set to show verbosity
LFLAG=""                #Set to List the Partitions
SFLAG=""                #Set to Show Size of Partitions
DFLAG=""                #Set to Delete Partitions
CFLAG=""                #Set to Create Partitions


usage() { 
  echo "Usage: $0 -hvldcs"
  echo "    -v Verbosity"
  echo "    -l List Partitions"
  echo "    -s Show Size"
  echo "    -d Delete Partitons"
  echo "    -c Create Partitons"
  exit 1
}



#Simple Verbosity Print Method
print_vmsg() {
    if [ -n "$VFLAG" ]; then
        echo $1
    fi
}

while getopts "hvlsdct" o;

do
    case "${o}" in
        v)
            VFLAG="1"
            ;;
        l)
            LFLAG="1"
            ;;
        s)
            SFLAG="1"
            ;;
        d)
            DFLAG="1"
            ;;
        c)
            CFLAG="1"
            ;;
        t)
            TFLAG="1"
            ;;
        *)
            usage
            ;;
    esac
done





THIS_SCRIPT=`basename $0`
print_vmsg "$THIS_SCRIPT: Version: $VERSION_NUM_MAJ.$VERSION_NUM_MIN"
print_vmsg "Release Status: $RELEASE_STATUS"

# Loop though all the sd* drives in /sys/block to see what is avalible
for DEV in /sys/block/sd*
    do
        print_vmsg "Pre DEV ${DEV}"
        DEV=`basename $DEV`
        print_vmsg "Post DEV ${DEV}"

        # Will not do anything if the drive they are looping on is the OS Drive
        #if [ "$DEV" != $OS_DRIVE ] || [ "$DEV" != $OS_DRIVE1 ] || [ "$DEV" != $OS_DRIVE2 ]; then
        #if [ $VENDOR = "Cypress" -o "$VENDOR" = "CiscoVD" ] || [ -n "$EXPECTED_YOSEMITE2" ] ; then
        if [[ $OS_DRIVE != *"$DEV"* ]]; then
            #print_vmsg "Not the Main OS Drive"

            # Lists out the Partition if the -l option is passed
            if [ -n "$LFLAG" ]; then
                print_vmsg "Going to List the Drives here..."
                fdisk -l /dev/${DEV}
                #parted /dev/${DEV} print
            fi

            # Displays the Size of each Partition if the -s option is passed
            if [ -n "$SFLAG" ]; then
                print_vmsg "Going to Size of the Drives here..."
            fi

            # Deletes the Partitions on the drive looped on
            if [ -n "$DFLAG" ]; then
                print_vmsg "Going to delete the Partition..."
                # Loops on and gets the Partition Number of the drive selected so we can delete it
                for v_partition in $(parted -s /dev/${DEV} print|awk '/^ / {print $1}')
                do
                    # Actually deletes the partition
                    print_vmsg "Going to delete $DEV partition $v_partition"
                    umount /dev/${DEV}
                    parted -s /dev/${DEV} rm ${v_partition}
                    sleep 1
                done
            fi

            # Creates the Partition on the Drive we are looping on.
            if [ -n "$CFLAG" ]; then
                print_vmsg "Going to Create the Partition..."
                sleep 1
                # Command to create new partition
                # n tells fdisk to create new partition
                # p tells to create Primary Partition
                # 1 Tells to create first Partition
                # " " selects default Values for the Start of the partition
                # " " selects default Values for the End of the partition
                # t sets the Partition Table
                # 33 Is Partition Table Type GPT
                # w writes teh values to disk.
                echo "g
                      n



                      w" | fdisk /dev/${DEV}
              sleep 1
            fi

            # Lists out the Partition if the -l option is passed
            if [ -n "$LFLAG" ]; then
                print_vmsg "Going to List the Drives here..."
                #fdisk -l /dev/${DEV}
                parted /dev/${DEV} print
            fi
            if [ -n "$TFLAG" ]; then
                print_vmsg "Going to Create the Partition..."
                sleep 5
                # Command to create new partition
                # n tells fdisk to create new partition
                # p tells to create Primary Partition
                # 1 Tells to create first Partition
                # " " selects default Values for the Start of the partition
                # " " selects default Values for the End of the partition
                # t sets the Partition Table
                # 33 Is Partition Table Type GPT
                # w writes teh values to disk.
                echo "n
                      p
                      1

                      +5G
                      n
                      p
                      2

                      +5G
                      n
                      p
                      3

                      +5G
                      n
                      p
                      4

                      +5G

                      t
                      83
                      w" | fdisk /dev/${DEV}
              sleep 5
            fi


        fi
    done






exit 1;

