#!/bin/sh
# Version 2.1 03/22/2013
VERSION_NUMBER_MAJOR="2"
VERSION_NUMBER_MINOR="1"
VERSION_NUMBER_MONTH="03"
VERSION_NUMBER_DAY="22"
VERSION_NUMBER_YEAR="2013"

#
# San Luis Server SD_Card USB disk test.
#

EXPECTED_DEVICE_COUNT_MIN=""
EXPECTED_DEVICE_COUNT_MAX=""
TEST_BLK_SIZE=""
TEST_BLK_COUNT=""
HFLAG=""
IFLAG=""
NFLAG=""
VFLAG=""
EXPECTED_YOSEMITE2=""
while getopts ':b:c:hinvx:y:T:s' OPTION
do
	case $OPTION in
		b)	TEST_BLK_SIZE="$OPTARG"
			;;  
		c)	TEST_BLK_COUNT="$OPTARG"
			;;  
		h)	HFLAG="1"
			;;  
		i)	IFLAG="1"
			NFLAG="1"
			;;  
		n)	NFLAG="1"
			;;  
		v)	VFLAG="1"
			;;  
		x)	EXPECTED_DEVICE_COUNT_MIN="$OPTARG"
			;;  
		y)	EXPECTED_DEVICE_COUNT_MAX="$OPTARG"
			;;  
		t)	TEST_TIME="$OPTARG"
			;;  
		s)	EXPECTED_YOSEMITE2="1"
			;;
		\?)	echo "Error: Invalid Option: -$OPTARG"
			exit -1
			;;  
		\:)	echo "Error: Flag Option -$OPTARG requires an argument."
			exit -1
			;;  
        esac
done
shift $(($OPTIND - 1))

if [ -n "$VFLAG" ] ; then
	THIS_SCRIPT=`basename $0`
	echo $THIS_SCRIPT\: Version\: $VERSION_NUMBER_MAJOR\.$VERSION_NUMBER_MINOR $VERSION_NUMBER_MONTH/$VERSION_NUMBER_DAY/$VERSION_NUMBER_YEAR
fi

if [ -n "$HFLAG" ] ; then
	THIS_SCRIPT=`basename $0`
	echo HELP\: $THIS_SCRIPT
	echo "	-b <blocksize>	# Size of test blocks."
	echo "	-c <count>	# Count of test blocks."
	echo "	-h 		# This Help output."
	echo "	-i 		# Get disk info.  Also implies -n flag."
	echo "	-n 		# No-Op flag.  Don't do anything."
	echo "	-v 		# Display Version."
	echo "	-x <count>	# Specify minimum expected SD disk count."
	echo "	-y <count>	# Specify maximum expected SD disk count."
	echo "  -T <seconds>	# Specify a certain time for disk test to run"
	echo "  -s		# Yosemite2 server SD disk test"
	echo
	echo "	NOTE: You need to run \"sdbootnopport\""
	echo "	      in BMC UDI diagnostic to enable"
	echo "	      SD cards to be visible in Host Linux."
fi

if [ -n "$HFLAG" -o -n "$VFLAG" ] ; then
	exit 0
fi

if [ -z "$TEST_TIME" ] ; then
	TEST_TIME="30" #run test for 30 seconds
fi

THIS_SCRIPT=`basename $0`
echo \[$THIS_SCRIPT\: Version\: $VERSION_NUMBER_MAJOR\.$VERSION_NUMBER_MINOR $VERSION_NUMBER_MONTH/$VERSION_NUMBER_DAY/$VERSION_NUMBER_YEAR\]

if [ -n "$TEST_BLK_SIZE" ] ; then
	DISKTEST_BLOCK_SIZE="$TEST_BLK_SIZE"
else
	DISKTEST_BLOCK_SIZE=4096
fi
if [ -n "$TEST_BLK_COUNT" ] ; then
	DISKTEST_BLOCK_COUNT="$TEST_BLK_COUNT"
else
	DISKTEST_BLOCK_COUNT=8000
fi

#echo EXPECTED_DEVICE_COUNT_MIN is $EXPECTED_DEVICE_COUNT_MIN
#echo EXPECTED_DEVICE_COUNT_MAX is $EXPECTED_DEVICE_COUNT_MAX
#echo NFLAG is $NFLAG

if [ -z "$IFLAG" ] ; then
	echo "-------------------------------------------------------"
	if [ -n "$EXPECTED_YOSEMITE2" ] ; then
		echo "Yosemite Server SD_Card USB disk test."
	else
		echo "San Luis Server SD_Card USB disk test."
	fi
	echo "-------------------------------------------------------"
	echo "	"DISKTEST_BLOCK_SIZE\: $DISKTEST_BLOCK_SIZE
	echo "	"DISKTEST_BLOCK_COUNT\: $DISKTEST_BLOCK_COUNT
fi

SD_DEVICE_FAILED="PASSED"
SD_DEVICE_COUNT=0
for i in /sys/block/sd* ; do
	VENDOR=`cat $i/device/vendor`
	VENDOR=`echo $VENDOR`
	DEVICE=`basename $i`
	#echo `basename $i` $VENDOR $MODEL

	#if [ "$VENDOR" = "HV" -a "$MODEL" = "Hypervisor_0" ] ; then
	if [ $VENDOR = "Cypress" -o "$VENDOR" = "CiscoVD" ] || [ -n "$EXPECTED_YOSEMITE2" ] ; then

		if [ \! -b "/dev/$DEVICE" ] ; then
		#	echo ISNOT-BLOCK-SPECIAL /dev/$DEVICE
			continue
		#else
		#	echo IS-BLOCK-SPECIAL /dev/$DEVICE
		fi


		SIZESTRING=`fdisk -l /dev/$DEVICE 2>/dev/null | grep Disk | grep bytes | cut -f 3-4,5-6 -d" "`

		if [ -n "$SIZESTRING" ]; then
			echo $SD_DEVICE_COUNT\: /dev/$DEVICE\: Vendor\:\"$VENDOR\" Model\:\"$MODEL\" Size\:\"$SIZESTRING\"
			let SD_DEVICE_COUNT+=1
			if [ -z "$NFLAG" ] ; then
				echo "	"disktest -b"$DISKTEST_BLOCK_SIZE" -c"$DISKTEST_BLOCK_COUNT" -p/dev/$DEVICE -T$TEST_TIME
				/root/bin/disktest -b"$DISKTEST_BLOCK_SIZE" -c"$DISKTEST_BLOCK_COUNT" -p/dev/$DEVICE  -T$TEST_TIME
				RETURN_CODE=$?
				#echo RETURN_CODE $RETURN_CODE
				if [ "$RETURN_CODE" -ne 0 ] ; then
					SD_DEVICE_FAILED="FAILED"
				fi
			else
				if [ -z "$IFLAG" ] ; then
					echo "	#"disktest -b"$DISKTEST_BLOCK_SIZE" -c"$DISKTEST_BLOCK_COUNT" -p/dev/$DEVICE  -T$TEST_TIME
				fi
			fi
		fi

		if [ -z "$IFLAG" ] ; then
			echo
		fi

	fi

done

COUNT_FAILED=""
if [ -n "$EXPECTED_DEVICE_COUNT_MIN" ] ; then
	if [ "$SD_DEVICE_COUNT" -lt "$EXPECTED_DEVICE_COUNT_MIN" ] ; then
		echo FAILED\: Found "$SD_DEVICE_COUNT" SD FLASH Drives, Minimum Expected "$EXPECTED_DEVICE_COUNT_MIN"
		COUNT_FAILED="FAILED"
		SD_DEVICE_FAILED="FAILED"
	fi
fi

if [ -n "$EXPECTED_DEVICE_COUNT_MAX" ] ; then
	if [ "$SD_DEVICE_COUNT" -gt "$EXPECTED_DEVICE_COUNT_MAX" ] ; then
		echo FAILED\: Found "$SD_DEVICE_COUNT" SD FLASH Drives, Maximum Expected "$EXPECTED_DEVICE_COUNT_MAX"
		COUNT_FAILED="FAILED"
		SD_DEVICE_FAILED="FAILED"
	fi
fi

if [ -z "$COUNT_FAILED" ] ; then
	echo "Drive Count Check: $SD_DEVICE_COUNT	PASSED"
fi
if [ "$SD_DEVICE_FAILED" = "PASSED" -a -z "$COUNT_FAILED" ] ; then
	echo All SD Drive Disktests: $SD_DEVICE_FAILED
else
	echo SD Drive Disktests: $SD_DEVICE_FAILED
fi

