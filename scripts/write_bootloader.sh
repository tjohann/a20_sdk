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
# Date/Beginn :    14.08.2016/15.07.2016
#
# Version     :    V1.03
#
# Milestones  :    V1.03 (aug 2016) -> finalize hdd installation
#                  V1.02 (aug 2016) -> be aware of hdd installation
#                  V1.01 (aug 2016) -> add features of make_sdcard.sh
#                  V1.00 (jul 2016) -> version bump
#                  V0.05 (jul 2016) -> relax unmount function error handling
#                  V0.04 (jul 2016) -> add comment
#                  V0.03 (jul 2016) -> redirect errors to >&2
#                  V0.02 (jul 2016) -> add first code
#                  V0.01 (jul 2016) -> initial version
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
VER='1.03'

# if env is sourced
MISSING_ENV='false'

# which brand?
BRAND='none'

# mountpoints
SD_KERNEL='none'
SD_SHARED='none'

# HDD installation?
PREP_HDD_INST='false'

# which devnode?
DEVNODE='none'

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
    echo "|        [-s] -> prepare sdcard as base for hdd instal.  |"
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
    # if something is still mounted
    umount_partitions

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
while getopts 'hvsb:d:' opts 2>$_log
do
    case $opts in
        h) my_usage ;;
        v) print_version ;;
        b) BRAND=$OPTARG ;;
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

if [[ ! ${ARMHF_SHARED} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${ARMHF_BIN_SHARED} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${ARMHF_SRC_SHARED} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${BANANAPI_SDCARD_KERNEL} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${OLIMEX_SDCARD_KERNEL} ]]; then
    MISSING_ENV='true'
fi

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
	echo "ERROR: ${DEVNODE} has already mounted partitions" >&2
	my_exit
    fi

    mounted=`echo ${DEVNODE} | awk -F '[/]' '{print $3}'`
    grep 1 /sys/block/${mounted}/removable 1>$_log
    if [ $? -ne 0 ]; then
	echo "ERROR: ${DEVNODE} has is not removeable device" >&2
	my_exit
    fi

    grep 0 /sys/block/${mounted}/ro 1>$_log
    if [ $? -ne 0 ]; then
	echo "ERROR: ${DEVNODE} is only readable" >&2
	my_exit
    fi
}

copy_bootloader()
{
    cd ${ARMHF_HOME}/${BRAND}/u-boot/

    # not really needed
    cp u-boot-sunxi-with-spl.bin boot.cmd boot.scr ${SD_KERNEL}/${BRAND}/

    cp u-boot-sunxi-with-spl.bin boot.cmd boot.scr ${SD_KERNEL}/
    if [ $? -ne 0 ]; then
	echo "ERROR: could not copy bootloader to ${SD_KERNEL}" >&2
	my_exit
    fi
}

write_bootloader()
{
    echo "sudo dd if=u-boot-sunxi-with-spl.bin of=${DEVNODE} bs=1024 seek=8"
    sudo dd if=u-boot-sunxi-with-spl.bin of=${DEVNODE} bs=1024 seek=8

    if [ $? -ne 0 ]; then
	echo "ERROR: could not write bootloader to ${DEVNODE}" >&2
	my_exit
    fi
}

umount_partitions()
{
    umount $SD_KERNEL
    if [ $? -ne 0 ]; then
	echo "ERROR -> could not umount ${SD_KERNEL}" >&2
	# do not exit -> will try to umount the others
    fi

    if [ "$PREP_HDD_INST" = 'true' ]; then
	umount $SD_SHARED
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not umount ${SD_HOME}" >&2
	fi
    fi
}

handle_hdd_parts()
{
    local src_hdd=${ARMHF_HOME}/${BRAND}/u-boot/

    if [[ ! -d "${SD_SHARED}" ]]; then
	echo "ERROR -> ${SD_SHARED} not available!"
	echo "         have you added them to your fstab? (see README.md)"
	my_usage
    fi

    mountpoint $SD_SHARED
    if [ $? -ne 0 ] ; then
	echo "${SD_SHARED} not mounted, i try it now"
	mount $SD_SHARED
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not mount ${SD_SHARED}"
	    my_exit
	fi
    fi

    echo "sudo mkdir ${SD_SHARED}/hdd_boot"
    sudo mkdir ${SD_SHARED}/hdd_boot
    if [ $? -ne 0 ] ; then
	echo "ERROR: could not create ${SD_SHARED}/hdd_boot" >&2
	my_exit
    fi

    echo "sudo cp ${src_hdd}/hdd_boot.tgz ${SD_SHARED}/hdd_boot"
    sudo cp ${src_hdd}/hdd_boot.tgz ${SD_SHARED}/hdd_boot
    if [ $? -ne 0 ] ; then
	echo "ERROR: could not copy ${src_hdd}/hdd_boot.tgz" >&2
	my_exit
    fi

    cp u-boot-sunxi-with-spl.bin boot.cmd boot.scr ${SD_SHARED}/hdd_boot
    if [ $? -ne 0 ]; then
	echo "ERROR: could not copy bootloader to ${SD_SHARED}" >&2
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
	SD_SHARED=$BANANAPI_SDCARD_SHARED
        ;;
    'bananapi-pro')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
	SD_SHARED=$BANANAPI_SDCARD_SHARED
        ;;
    'baalue')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
	SD_SHARED=$BANANAPI_SDCARD_SHARED
        ;;
    'olimex')
	SD_KERNEL=$OLIMEX_SDCARD_KERNEL
	SD_SHARED=$OLIMEX_SDCARD_SHARED
        ;;
    'cubietruck')
	SD_KERNEL=$CUBIETRUCK_SDCARD_KERNEL
	SD_SHARED=$CUBIETRUCK_SDCARD_SHARED
        ;;
    *)
        echo "ERROR -> ${BRAND} is not supported ... pls check" >&2
        my_exit
esac

if [[ ! -d "${SD_KERNEL}" ]]; then
    echo "ERROR -> ${SD_KERNEL} not available!" >&2
    echo "         have you added them to your fstab? (see README.md)" >&2
    my_exit
fi

mount $SD_KERNEL
if [ $? -ne 0 ]; then
    echo "ERROR -> could not mount ${SD_KERNEL}" >&2
    my_exit
fi

if [[ ! -d "${ARMHF_HOME}/${BRAND}/u-boot" ]]; then
    echo "ERROR -> ${SD_KERNEL} not available!" >&2
    echo "         have you added them to your fstab? (see README.md)" >&2
    my_exit
fi

copy_bootloader
write_bootloader

if [ "$PREP_HDD_INST" = 'true' ]; then
    handle_hdd_parts
fi

umount_partitions

cleanup
echo " "
echo "+------------------------------------------+"
echo "|             Cheers $USER                  "
echo "+------------------------------------------+"
echo " "
