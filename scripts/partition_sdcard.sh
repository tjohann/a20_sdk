#!/usr/bin/env bash
################################################################################
#
# Title       :    partition_sdcard.sh
#
# License:
#
# GPL
# (c) 2016, thorsten.johannvorderbrueggen@t-online.de
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
# Date/Beginn :    11.07.2016/07.07.2016
#
# Version     :    V0.02
#
# Milestones  :    V0.02 (jul 2016) -> add support for baalue
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
VER='0.02'

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
PREP_HDD_INST='none'

# use only base image
BASE_IMAGE='none'

# minimal size of a SD-Card
# 4G for minimal image
# 8G for full image
MIN_SD_SIZE_FULL=16580608
MIN_SD_SIZE_SMALL=8388608

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "|                                                        |"
    echo "| Usage: ./partition_sdcard.sh                           |"
    echo "|        [-d] -> sd-device /dev/sdd ... /dev/mmcblk ...  |"
    echo "|        [-b] -> bananapi/bananapi-pro/olimex/baalue/    |"
    echo "|                cubietruck                              |"
    echo "|        [-m] -> download the minimal images             |"
    echo "|        [-s] -> prepare images for hdd installation     |"
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
    echo "+-----------------------------------+"
    echo "| You are using version: ${VER}       |"
    echo "+-----------------------------------+"
    cleanup
    exit
}

# ---- Some values for internal use ----
_temp="/tmp/partition_sdcard.$$"
_log="/tmp/partition_sdcard.log"


# check the args
while getopts 'hvmb:d:' opts 2>$_log
do
    case $opts in
        h) my_usage ;;
        v) print_version ;;
        b) BRAND=$OPTARG ;;
	m) BASE_IMAGE='true' ;;
	d) DEVNODE=$OPTARG ;;
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

# bananapi-{M1/Pro}
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

# cubietruck
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
    exit
fi


# ******************************************************************************
# ***                      The functions for main_menu                       ***
# ******************************************************************************

check_devnode()
{
    local mounted=`grep ${DEVNODE} /proc/mounts | sort | cut -d ' ' -f 1`
    if [[ "${mounted}" ]]; then
	echo "ERROR: ${DEVNODE} has already mounted partitions"
	my_exit
    fi

    mounted=`echo ${DEVNODE} | awk -F '[/]' '{print $3}'`
    grep 1 /sys/block/${mounted}/removable 1>$_log
    if [ $? -ne 0 ] ; then
	echo "ERROR: ${DEVNODE} has is not removeable device"
	my_exit
    fi

    grep 0 /sys/block/${mounted}/ro 1>$_log
    if [ $? -ne 0 ] ; then
	echo "ERROR: ${DEVNODE} is only readable"
	my_exit
    fi

    local size=$(< /sys/block/${mounted}/size)
    if [[ "$size" -lt "$MIN_SD_SIZE_FULL" ]]; then
	echo "ERROR: ${DEVNODE} is to small with ${size} sectors"
	my_exit
    fi
}

check_directories()
{
    if [[ ! -d "${SD_KERNEL}" ]]; then
	echo "ERROR -> ${SD_KERNEL} not available!"
	echo "         have you added them to your fstab? (see README.md)"
	my_exit
    fi

    if [[ ! -d "${SD_ROOTFS}" ]]; then
	echo "ERROR -> ${SD_ROOTFS} not available!"
	echo "         have you added them to your fstab? (see README.md)"
	my_exit
    fi

    #
    # if HDD installation:
    # -> root only min image
    # -> no home
    # -> content on shared
    if [[ ! -d "${SD_HOME}" ]]; then
	echo "ERROR -> ${SD_HOME} not available!"
	echo "         have you added them to your fstab? (see README.md)"
	my_exit
    fi

#    if [[ ! -d "${SD_SHARED}" ]]; then
#	echo "ERROR -> ${SD_SHARED} not available!"
#	echo "         have you added them to your fstab? (see README.md)"
#	my_exit
#    fi
}

clean_sdcard()
{
    echo "sudo dd if=/dev/zero of=${DEVNODE} bs=1k count=1023 seek=1"
    #sudo dd if=/dev/zero of=${DEVNODE} bs=1k count=1023 seek=1
    if [ $? -ne 0 ] ; then
	echo "ERROR: could not clear ${DEVNODE}"
	my_exit
    fi
}

partition_sdcard()
{
    if [ "$BASE_IMAGE" = 'true' ]; then
	local layout=${ARMHF_HOME}/${BRAND}/configs/partition.layout
    else
	local layout=${ARMHF_HOME}/${BRAND}/configs/partition_base.layout
    fi
    
    if [[ ! -f "$layout" ]]; then
	echo "ERROR: parition layout ${layout} does not exist ... check your repo"
	my_exit
    fi

    #
    # if HDD installation:
    # -> root only min image
    # -> no home
    # -> content on shared

    echo "sudo sfdisk ${DEVNODE} < ${layout}"
    #sudo sfdisk ${DEVNODE} < ${layout}
    if [ $? -ne 0 ] ; then
	echo "ERROR: could not write parition layout ${layout}"
	my_exit
    fi
}

format_partitions()
{
    #
    # if HDD installation:
    # -> root only min image
    # -> no home
    # -> content on shared

    echo "sudo mkfs.vfat -F 32 -n KERNEL_${SD_PART_NAME_POST_LABEL} ${DEVNODE}1"
    #sudo mkfs.vfat -F 32 -n KERNEL_${SD_PART_NAME_POST_LABEL} ${DEVNODE}1
    if [ $? -ne 0 ] ; then
	echo "ERROR: could not format parition ${DEVNODE}1"
	my_exit
    fi

    echo "sudo mkfs.ext4 -O ^has_journal -L ROOTFS_${SD_PART_NAME_POST_LABEL} ${DEVNODE}2"
    #sudo mkfs.ext4 -O ^has_journal -L ROOTFS_${SD_PART_NAME_POST_LABEL} ${DEVNODE}2
    if [ $? -ne 0 ] ; then
	echo "ERROR: could not format parition ${DEVNODE}2"
	my_exit
    fi

    echo "sudo mkfs.ext4 -O ^has_journal -L HOME_${SD_PART_NAME_POST_LABEL} ${DEVNODE}3"
    #sudo mkfs.ext4 -O ^has_journal -L HOME_${SD_PART_NAME_POST_LABEL} ${DEVNODE}3
    if [ $? -ne 0 ] ; then
	echo "ERROR: could not format parition ${DEVNODE}3"
	my_exit
    fi

    echo "sudo mkswap ${DEVNODE}4"
    #sudo mkswap ${DEVNODE}4
    if [ $? -ne 0 ] ; then
	echo "ERROR: could not format parition ${DEVNODE}4"
	my_exit
    fi
}

mount_partitions()
{
    mount $SD_KERNEL
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not mount ${SD_KERNEL}"
	my_exit
    fi

    mount $SD_ROOTFS
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not mount ${SD_ROOTFS}"
	my_exit
    fi

    #
    # if HDD installation:
    # -> root only min image
    # -> no home
    # -> content on shared
    mount $SD_HOME
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not mount ${SD_HOME}"
	my_exit
    fi

#    mount $SD_SHARED
#    if [ $? -ne 0 ] ; then
#	echo "ERROR -> could not mount ${SD_SHARED}"
#	my_exit
#    fi
}

umount_partitions()
{
    umount $SD_KERNEL
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not umount ${SD_KERNEL}"
	my_exit
    fi

    umount $SD_ROOTFS
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not umount ${SD_ROOTFS}"
	my_exit
    fi

    #
    # if HDD installation:
    # -> root only min image
    # -> no home
    # -> content on shared
    umount $SD_HOME
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not umount ${SD_HOME}"
	my_exit
    fi

#    umount $SD_SHARED
#    if [ $? -ne 0 ] ; then
#	echo "ERROR -> could not umount ${SD_SHARED}"
#	my_exit
#    fi
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

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
    *)
        echo "ERROR -> ${BRAND} is not supported ... pls check"
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
echo "| --> prepare your password for sudo       |"
echo "+------------------------------------------+"
clean_sdcard

echo " "
echo "+------------------------------------------+"
echo "| start paritioning $DEVNODE                "
echo "| --> prepare your password for sudo       |"
echo "+------------------------------------------+"
partition_sdcard

echo " "
echo "+------------------------------------------+"
echo "| start formating the partitions           |"
echo "| --> prepare your password for sudo       |"
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
