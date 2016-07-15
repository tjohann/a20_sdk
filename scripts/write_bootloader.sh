#!/usr/bin/env bash
################################################################################
#
# Title       :    write_bootloader.sh
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
# Date/Beginn :    15.07.2016/15.07.2016
#
# Version     :    V0.01
#
# Milestones  :    V0.01 (jul 2016) -> initial version
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to write u-boot to a sd-card
#
# Some features
#   - ...
#
################################################################################
#

# VERSION-NUMBER
VER='0.01'

# if env is sourced
MISSING_ENV='false'

# which brand?
BRAND='none'

# mountpoints
SD_KERNEL='none'

# which devnode?
DEVNODE='none'

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "|                                                        |"
    echo "| Usage: ./write_bootloader.sh                              |"
    echo "|        [-d] -> sd-device /dev/sdd ... /dev/mmcblk ...  |"
    echo "|        [-b] -> bananapi/bananapi-pro/olimex/baalue/    |"
    echo "|                cubietruck                              |"
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
_temp="/tmp/write_bootloader.$$"
_log="/tmp/write_bootloader.log"


# check the args
while getopts 'hvb:d:' opts 2>$_log
do
    case $opts in
        h) my_usage ;;
        v) print_version ;;
        b) BRAND=$OPTARG ;;
	d) DEVNODE=$OPTARG ;;
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

# olimex
if [[ ! ${OLIMEX_SDCARD_KERNEL} ]]; then
    MISSING_ENV='true'
fi

# cubietruck
if [[ ! ${CUBIETRUCK_SDCARD_KERNEL} ]]; then
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
}

check_directories()
{
    if [[ ! -d "${SD_KERNEL}" ]]; then
	echo "ERROR -> ${SD_KERNEL} not available!"
	echo "         have you added them to your fstab? (see README.md)"
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
}

umount_partitions()
{
    umount $SD_KERNEL
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not umount ${SD_KERNEL}"
	my_exit
    fi
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
        ;;
    'bananapi-pro')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
        ;;
    'baalue')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
        ;;
    'olimex')
	SD_KERNEL=$OLIMEX_SDCARD_KERNEL
        ;;
    'cubietruck')
	SD_KERNEL=$CUBIETRUCK_SDCARD_KERNEL
        ;;
    *)
        echo "ERROR -> ${BRAND} is not supported ... pls check"
        my_exit
esac

#
# write bootloader
#

check_directories
mount_partitions
#
# copy bootloader to sd-card
#
umount_partitions

cleanup
echo " "
echo "+------------------------------------------+"
echo "|             Cheers $USER                  "
echo "+------------------------------------------+"
echo " "
