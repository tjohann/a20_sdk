#!/usr/bin/env bash
################################################################################
#
# Title       :    format_sdcard.sh
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
# Date/Beginn :    27.09.2016/12.07.2016
#
# Version     :    V2.00
#
# Milestones  :    V2.00 (sep 2016) -> update version info fo A20_SDK_V2.0.0
#                  V1.03 (aug 2016) -> add hdd-only-sdcard parts
#                  V1.02 (aug 2016) -> sudo handling at beginning
#                  V1.01 (jul 2016) -> add features of make_sdcard.sh
#                  V1.00 (jul 2016) -> version bump
#                  V0.05 (jul 2016) -> relax unmount function error handling
#                  V0.04 (jul 2016) -> redirect errors to >&2
#                  V0.03 (jul 2016) -> some smaller cleanups
#                  V0.02 (jul 2016) -> add check for device-nodes
#                                      some smaller improvements
#                  V0.01 (jul 2016) -> initial version
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to format a sdcard
#
# Some features
#   - ...
#
################################################################################
#

# VERSION-NUMBER
VER='2.00'

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

# HDD-boot only sd-card?
HDD_BOOT_SDCARD='false'

# HDD installation?
PREP_HDD_INST='false'

# program name
PROGRAM_NAME=${0##*/}

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "|                                                        |"
    echo "| Usage: ${PROGRAM_NAME} "
    echo "|        [-d] -> sd-device /dev/sdd ... /dev/mmcblk ...  |"
    echo "|        [-b] -> bananapi/bananapi-pro/olimex/baalue/    |"
    echo "|                cubietruck                              |"
    echo "|        [-s] -> prepare sd-card for hdd installation    |"
    echo "|        [-e] -> prepare partitions for hdd-boot-only    |"
    echo "|                -e set also -s                          |"
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
while getopts 'hvseb:d:' opts 2>$_log
do
    case $opts in
        h) my_usage ;;
        v) print_version ;;
        b) BRAND=$OPTARG ;;
	d) DEVNODE=$OPTARG ;;
	s) PREP_HDD_INST='true' ;;
	e) HDD_BOOT_SDCARD='true' ;;
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

# bananapi-{M1/Pro}/baalue
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
	echo "ERROR: ${DEVNODE} is only readable"
	my_exit
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
	# do not exit -> will try to umount the others
    fi

    umount $SD_ROOTFS
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not umount ${SD_ROOTFS}" >&2
	# do not exit -> will try to umount the others
    fi

    if [ "$PREP_HDD_INST" = 'true' ]; then
	umount $SD_SHARED
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not umount ${SD_SHARED}" >&2
	    # do not exit -> will try to umount the others
	fi
    else
	umount $SD_HOME
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not umount ${SD_HOME}" >&2
	    # do not exit -> will try to umount the others
	fi
    fi
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

# sudo handling up-front
echo " "
echo "+------------------------------------------+"
echo "| format a sd-card                         |"
echo "| --> need sudo for some parts             |"
echo "+------------------------------------------+"
echo " "

sudo -v
# keep-alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# check conditions HDD_BOOT_SDCARD without PREP_HDD_INST makes no sense
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
        echo "ERROR -> ${BRAND} is not supported ... pls check" >&2
        my_exit
esac

echo " "
echo "+------------------------------------------+"
echo "| check needed directories                 |"
echo "+------------------------------------------+"
check_directories

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
