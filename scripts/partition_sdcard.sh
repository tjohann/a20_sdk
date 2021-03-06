#!/usr/bin/env bash
################################################################################
#
# Title       :    partition_sdcard.sh
#
# License:
#
# GPL
# (c) 2016-2021, thorsten.johannvorderbrueggen@t-online.de
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
################################################################################
#
# Date/Beginn :    20.04.2021/07.07.2016
#
# Version     :    V2.07
#
# Milestones  :    V2.07 (apr 2021) -> change size of base image to 6Gig
#                  V2.06 (jul 2020) -> add support for orangepi-zero
#                  V2.05 (jun 2020) -> fix bug in clean_sdcard function
#                  V2.04 (apr 2020) -> add support for bananapi-m3
#                  V2.03 (aug 2017) -> add support for cubietruck-plus
#                  V2.02 (feb 2017) -> increase size of root partitions to 4/8Gig
#                  V2.01 (nov 2016) -> add support for nanopi-neo
#                  V2.00 (sep 2016) -> update version info fo A20_SDK_V2.0.0
#                  V1.05 (aug 2016) -> add partprobe to inform kernel of changes
#                                      clear also partition table
#                  V1.04 (aug 2016) -> sudo handling at beginning
#                  V1.03 (aug 2016) -> add hdd-only-sdcard parts
#                  V1.02 (aug 2016) -> add features of make_sdcard.sh
#                  V1.01 (jul 2016) -> increase size of small rootfs to 3Gig
#                  V1.00 (jul 2016) -> version bump
#                  V0.05 (jul 2016) -> some smaller cleanups
#                  V0.04 (jul 2016) -> add check for device-nodes
#                                      some smaller improvements
#                  V0.03 (jul 2016) -> prepare hdd installation
#                                      fix sfdisk behaviour
#                  V0.02 (jul 2016) -> add support for baalue
#                                      add first support for hdd installation
#                                      change exit code to 3
#                                      start to support base image
#                  V0.01 (jul 2016) -> initial version
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to create a partition table on a sdcard
#
# Some features
#   - ...
#
################################################################################
#

# VERSION-NUMBER
VER='2.06'

# if env is sourced
MISSING_ENV='false'

# which brand?
BRAND='none'

# mountpoints
SD_KERNEL='none'
SD_ROOTFS='none'
SD_HOME='none'
SD_SHARED='none'

# which devnode?
DEVNODE='none'

# HDD installation?
PREP_HDD_INST='false'

# HDD-boot only sd-card?
HDD_BOOT_SDCARD='false'

# use only base image
BASE_IMAGE='false'

# minimal size of a SD-Card
# 6G for minimal/musl image
# 8G for full/glibc image
MIN_SD_SIZE_FULL=15000000
MIN_SD_SIZE_SMALL=10000000

# addition to patitionlabel (like KERNEL_BANA or ROOTFS_OLI)
SD_PART_NAME_POST_LABEL='none'

# program name
PROGRAM_NAME=${0##*/}

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "|                                                        |"
    echo "| Usage:  ${PROGRAM_NAME} "
    echo "|        [-d] -> sd-device /dev/sdd ... /dev/mmcblk ...  |"
    echo "|        [-b] -> bananapi/bananapi-pro/olimex/baalue/    |"
    echo "|                cubietruck/cubietruck-plus/nanopi/      |"
    echo "|                bananapi-m3/orangepi-zero               |"
    echo "|        [-m] -> partition for the minimal/musl imag     |"
    echo "|        [-s] -> prepare partitions for hdd installation |"
    echo "|        [-e] -> prepare partitions for hdd-boot-only    |"
    echo "|                will automatically set also -s          |"
    echo "|        [-v] -> print version info                      |"
    echo "|        [-h] -> this help                               |"
    echo "|                                                        |"
    echo "+--------------------------------------------------------+"
    echo " "
    exit
}

# my cleanup
cleanup() {
    rm $_temp 2>/dev/null
    rm $_log 2>/dev/null
}

# my exit method
my_exit()
{
    echo "+-----------------------------------+"
    echo "|          Cheers $USER            |"
    echo "+-----------------------------------+"
    cleanup
    # http://tldp.org/LDP/abs/html/exitcodes.html
    exit 3
}

# print version info
print_version()
{
    echo "+------------------------------------------------------------+"
    echo "| You are using ${PROGRAM_NAME} with version ${VER} "
    echo "+------------------------------------------------------------+"
    cleanup
    exit
}

# --- Some values for internal use
_temp="/tmp/${PROGRAM_NAME}.$$"
_log="/tmp/${PROGRAM_NAME}.$$.log"


# check the args
while getopts 'hsvmeb:d:' opts 2>$_log
do
    case $opts in
        h) my_usage ;;
        v) print_version ;;
        b) BRAND=$OPTARG ;;
	m) BASE_IMAGE='true' ;;
	d) DEVNODE=$OPTARG ;;
	e) HDD_BOOT_SDCARD='true' ;;
	s) PREP_HDD_INST='true' ;;
        ?) my_usage ;;
    esac
done


# ******************************************************************************
# ***             Error handling for missing shell values                    ***
# ******************************************************************************

if [[ ! ${ARMHF_HOME} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${ARMHF_BIN_HOME} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${ARMHF_SRC_HOME} ]]; then
    MISSING_ENV='true'
fi

# bananapi-{M1/M3/Pro}/baalue
if [[ ! ${BANANAPI_SDCARD_KERNEL} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${BANANAPI_SDCARD_ROOTFS} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${BANANAPI_SDCARD_HOME} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${BANANAPI_SDCARD_SHARED} ]]; then
    MISSING_ENV='true'
fi

# olimex
if [[ ! ${OLIMEX_SDCARD_KERNEL} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${OLIMEX_SDCARD_ROOTFS} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${OLIMEX_SDCARD_HOME} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${OLIMEX_SDCARD_SHARED} ]]; then
    MISSING_ENV='true'
fi

# cubietruck/cubietruck-plus
if [[ ! ${CUBIETRUCK_SDCARD_KERNEL} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${CUBIETRUCK_SDCARD_ROOTFS} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${CUBIETRUCK_SDCARD_HOME} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${CUBIETRUCK_SDCARD_SHARED} ]]; then
    MISSING_ENV='true'
fi

# nanopi
if [[ ! ${NANOPI_SDCARD_KERNEL} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${NANOPI_SDCARD_ROOTFS} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${NANOPI_SDCARD_HOME} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${NANOPI_SDCARD_SHARED} ]]; then
    MISSING_ENV='true'
fi

# orangepi
if [[ ! ${ORANGEPI_SDCARD_KERNEL} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${ORANGEPI_SDCARD_ROOTFS} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${ORANGEPI_SDCARD_HOME} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${ORANGEPI_SDCARD_SHARED} ]]; then
    MISSING_ENV='true'
fi

# show a usage screen and exit
if [ "$MISSING_ENV" = 'true' ]; then
    cleanup
    echo " "
    echo "+--------------------------------------+"
    echo "|                                      |"
    echo "|  ERROR: missing env                  |"
    echo "|         have you sourced env-file?   |"
    echo "|                                      |"
    echo "|          Cheers $USER               |"
    echo "|                                      |"
    echo "+--------------------------------------+"
    echo " "
    exit 3
fi


# ******************************************************************************
# ***                      The functions for main_menu                       ***
# ******************************************************************************

check_devnode()
{
    local mounted=`grep ${DEVNODE} /proc/mounts | sort | cut -d ' ' -f 1`
    if [[ "${mounted}" ]]; then
	echo "ERROR: ${DEVNODE} has already mounted partitions" >&2
	my_exit
    fi

    mounted=`echo ${DEVNODE} | awk -F '[/]' '{print $3}'`
    grep 1 /sys/block/${mounted}/removable 1>$_log
    if [ $? -ne 0 ] ; then
	echo "ERROR: ${DEVNODE} has is not removeable device" >&2
	my_exit
    fi

    grep 0 /sys/block/${mounted}/ro 1>$_log
    if [ $? -ne 0 ] ; then
	echo "ERROR: ${DEVNODE} is only readable" >&2
	my_exit
    fi

    if [ "$HDD_BOOT_SDCARD" = 'true' ]; then
	echo "No check of size needed"
    else
	local size=$(< /sys/block/${mounted}/size)
	if [ "$BASE_IMAGE" = 'true' ]; then
	    if [[ "$size" -lt "$MIN_SD_SIZE_SMALL" ]]; then
		echo "ERROR: ${DEVNODE} is to small with ${size} sectors" >&2
		my_exit
	    fi
	else
	    if [[ "$size" -lt "$MIN_SD_SIZE_FULL" ]]; then
		echo "ERROR: ${DEVNODE} is to small with ${size} sectors" >&2
		my_exit
	    fi
	fi
    fi
}

check_directories()
{
    if [[ ! -d "${SD_KERNEL}" ]]; then
	echo "ERROR -> ${SD_KERNEL} not available!" >&2
	echo "         have you added them to your fstab? (see README.md)" >&2
	my_exit
    fi

    if [[ ! -d "${SD_ROOTFS}" ]]; then
	echo "ERROR -> ${SD_ROOTFS} not available!" >&2
	echo "         have you added them to your fstab? (see README.md)" >&2
	my_exit
    fi

    if [ "$PREP_HDD_INST" = 'true' ]; then
	if [[ ! -d "${SD_SHARED}" ]]; then
	    echo "ERROR -> ${SD_SHARED} not available!" >&2
	    echo "         have you added them to your fstab? (see README.md)" >&2
	    my_exit
	fi
    else
	if [[ ! -d "${SD_HOME}" ]]; then
	    echo "ERROR -> ${SD_HOME} not available!" >&2
	    echo "         have you added them to your fstab? (see README.md)" >&2
	    my_exit
	fi
    fi
}

clean_sdcard()
{
    # keep old partition table
    # echo "sudo dd if=/dev/zero of=${DEVNODE} bs=1k count=1023 seek=1"
    # sudo dd if=/dev/zero of=${DEVNODE} bs=1k count=1023 seek=1

    # clear also partition table
    echo "sudo dd if=/dev/zero of=${DEVNODE} bs=1M count=1"
    sudo dd if=/dev/zero of=${DEVNODE} bs=1M count=1
    if [ $? -ne 0 ] ; then
	echo "ERROR: could not clear ${DEVNODE}" >&2
	my_exit
    fi

    sudo partprobe ${DEVNODE}
}

partition_sdcard()
{
    if [ "$BASE_IMAGE" = 'true' ]; then
	sudo blockdev --rereadpt ${DEVNODE}
	cat <<EOT | sudo sfdisk ${DEVNODE}
1M,32M,c
,6G,L
,,L
EOT
    else
	sudo blockdev --rereadpt ${DEVNODE}
	cat <<EOT | sudo sfdisk ${DEVNODE}
1M,32M,c
,8G,L
,,L
EOT
    fi

    if [ $? -ne 0 ] ; then
	echo "ERROR: could not create partitions" >&2
	my_exit
    fi

    sudo partprobe ${DEVNODE}
}

partition_hdd_boot_sdcard()
{
    sudo blockdev --rereadpt ${DEVNODE}
    cat <<EOT | sudo sfdisk ${DEVNODE}
1M,32M,c
,100M,L
,,L
EOT

    if [ $? -ne 0 ] ; then
	echo "ERROR: could not create partitions" >&2
	my_exit
    fi

    sudo partprobe ${DEVNODE}
}

format_partitions()
{
    if [[ -b ${DEVNODE}1 ]]; then
	echo "sudo mkfs.vfat -F 32 -n KERNEL_${SD_PART_NAME_POST_LABEL} ${DEVNODE}1"
	sudo mkfs.vfat -F 32 -n KERNEL_${SD_PART_NAME_POST_LABEL} ${DEVNODE}1
	if [ $? -ne 0 ] ; then
	    echo "ERROR: could not format parition ${DEVNODE}1" >&2
	    my_exit
	fi
    else
	echo "ERROR -> ${DEVNODE}1 not available" >&2
    fi

    if [[ -b ${DEVNODE}2 ]]; then
	echo "sudo mkfs.ext4 -O ^has_journal -L ROOTFS_${SD_PART_NAME_POST_LABEL} ${DEVNODE}2"
	sudo mkfs.ext4 -O ^has_journal -L ROOTFS_${SD_PART_NAME_POST_LABEL} ${DEVNODE}2
	if [ $? -ne 0 ] ; then
	    echo "ERROR: could not format parition ${DEVNODE}2" >&2
	    my_exit
	fi
    else
	echo "ERROR -> ${DEVNODE}2 not available" >&2
    fi

    if [[ -b ${DEVNODE}3 ]]; then
	if [ "$PREP_HDD_INST" = 'true' ]; then
	    echo "sudo mkfs.ext4 -O ^has_journal -L SHARED_${SD_PART_NAME_POST_LABEL} ${DEVNODE}3"
	    sudo mkfs.ext4 -O ^has_journal -L SHARED_${SD_PART_NAME_POST_LABEL} ${DEVNODE}3
	    if [ $? -ne 0 ] ; then
		echo "ERROR: could not format parition ${DEVNODE}3" >&2
		my_exit
	    fi
	else
	    echo "sudo mkfs.ext4 -O ^has_journal -L HOME_${SD_PART_NAME_POST_LABEL} ${DEVNODE}3"
	    sudo mkfs.ext4 -O ^has_journal -L HOME_${SD_PART_NAME_POST_LABEL} ${DEVNODE}3
	    if [ $? -ne 0 ] ; then
		echo "ERROR: could not format parition ${DEVNODE}3" >&2
		my_exit
	    fi
	fi
    else
	echo "ERROR -> ${DEVNODE}3 not available" >&2
    fi
}

mount_partitions()
{
    mount $SD_KERNEL
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not mount ${SD_KERNEL}" >&2
	my_exit
    fi

    mount $SD_ROOTFS
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not mount ${SD_ROOTFS}" >&2
	my_exit
    fi

    if [ "$PREP_HDD_INST" = 'true' ]; then
	mount $SD_SHARED
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not mount ${SD_SHARED}" >&2
	    my_exit
	fi
    else
	mount $SD_HOME
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not mount ${SD_HOME}" >&2
	    my_exit
	fi
    fi
}

umount_partitions()
{
    umount $SD_KERNEL
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not umount ${SD_KERNEL}" >&2
	my_exit
    fi

    umount $SD_ROOTFS
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not umount ${SD_ROOTFS}" >&2
	my_exit
    fi

    if [ "$PREP_HDD_INST" = 'true' ]; then
	umount $SD_SHARED
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not umount ${SD_SHARED}" >&2
	    my_exit
	fi
    else
	umount $SD_HOME
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not umount ${SD_HOME}" >&2
	    my_exit
	fi
    fi
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

# sudo handling up-front
echo " "
echo "+------------------------------------------+"
echo "| partition sd-card                        |"
echo "| --> need sudo for some parts             |"
echo "+------------------------------------------+"
echo " "

sudo -v
# keep-alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# check conditions HDD_BOOT_SDCARD without HDD_BOOT_SDCARD makes no sense
if [ "$HDD_BOOT_SDCARD" = 'true' ]; then
    PREP_HDD_INST='true'
fi

echo " "
echo "+------------------------------------------+"
echo "| do some testing on $DEVNODE ...           "
echo "+------------------------------------------+"
check_devnode

case "$BRAND" in
    'bananapi')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
	SD_HOME=$BANANAPI_SDCARD_HOME
	SD_SHARED=$BANANAPI_SDCARD_SHARED
	SD_PART_NAME_POST_LABEL="BANA"
        ;;
    'bananapi-pro')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
	SD_HOME=$BANANAPI_SDCARD_HOME
	SD_SHARED=$BANANAPI_SDCARD_SHARED
	SD_PART_NAME_POST_LABEL="BANA"
        ;;
    'bananapi-m3')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
	SD_HOME=$BANANAPI_SDCARD_HOME
	SD_SHARED=$BANANAPI_SDCARD_SHARED
	SD_PART_NAME_POST_LABEL="BANA"
        ;;
    'baalue')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
	SD_HOME=$BANANAPI_SDCARD_HOME
	SD_SHARED=$BANANAPI_SDCARD_SHARED
	SD_PART_NAME_POST_LABEL="BANA"
        ;;
    'olimex')
	SD_KERNEL=$OLIMEX_SDCARD_KERNEL
	SD_ROOTFS=$OLIMEX_SDCARD_ROOTFS
	SD_HOME=$OLIMEX_SDCARD_HOME
	SD_SHARED=$OLIMEX_SDCARD_SHARED
	SD_PART_NAME_POST_LABEL="OLI"
        ;;
    'cubietruck')
	SD_KERNEL=$CUBIETRUCK_SDCARD_KERNEL
	SD_ROOTFS=$CUBIETRUCK_SDCARD_ROOTFS
	SD_HOME=$CUBIETRUCK_SDCARD_HOME
	SD_SHARED=$CUBIETRUCK_SDCARD_SHARED
	SD_PART_NAME_POST_LABEL="CUBI"
        ;;
    'cubietruck-plus')
	SD_KERNEL=$CUBIETRUCK_SDCARD_KERNEL
	SD_ROOTFS=$CUBIETRUCK_SDCARD_ROOTFS
	SD_HOME=$CUBIETRUCK_SDCARD_HOME
	SD_SHARED=$CUBIETRUCK_SDCARD_SHARED
	SD_PART_NAME_POST_LABEL="CUBI"
        ;;
     'nanopi')
	SD_KERNEL=$NANOPI_SDCARD_KERNEL
	SD_ROOTFS=$NANOPI_SDCARD_ROOTFS
	SD_HOME=$NANOPI_SDCARD_HOME
	SD_SHARED=$NANOPI_SDCARD_SHARED
	SD_PART_NAME_POST_LABEL="NANO"
        ;;
     'orangepi-zero')
	SD_KERNEL=$ORANGEPI_SDCARD_KERNEL
	SD_ROOTFS=$ORANGEPI_SDCARD_ROOTFS
	SD_HOME=$ORANGEPI_SDCARD_HOME
	SD_SHARED=$ORANGEPI_SDCARD_SHARED
	SD_PART_NAME_POST_LABEL="ORAN"
        ;;
    *)
        echo "ERROR -> ${BRAND} is not supported ... pls check" >&2
        my_usage
esac

echo " "
echo "+------------------------------------------+"
echo "| check needed directories                 |"
echo "+------------------------------------------+"
check_directories

echo " "
echo "+------------------------------------------+"
echo "| clean $DEVNODE ...                        "
echo "+------------------------------------------+"
clean_sdcard

echo " "
echo "+------------------------------------------+"
echo "| start paritioning $DEVNODE                "
echo "+------------------------------------------+"
if [ "$HDD_BOOT_SDCARD" = 'true' ]; then
    partition_hdd_boot_sdcard
else
    partition_sdcard
fi

echo " "
echo "+------------------------------------------+"
echo "| start formating the partitions           |"
echo "+------------------------------------------+"
format_partitions

echo " "
echo "+------------------------------------------+"
echo "| check if we can mount the partitions     |"
echo "+------------------------------------------+"
mount_partitions

echo " "
echo "+------------------------------------------+"
echo "| check if we can umount the partitions    |"
echo "+------------------------------------------+"
umount_partitions

echo " "
echo "+------------------------------------------+"
echo "| $DEVNODE is ready to use                  "
echo "+------------------------------------------+"

cleanup
echo " "
echo "+------------------------------------------+"
echo "|             Cheers $USER                  "
echo "+------------------------------------------+"
echo " "
