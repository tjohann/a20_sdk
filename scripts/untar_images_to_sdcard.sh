#!/usr/bin/env bash
################################################################################
#
# Title       :    untar_images_to_sdcard.sh
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
#   A simple tool to untar downloaded images to a sd-card
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
SD_ROOTFS='none'
SD_HOME='none'
SD_SHARED='none'

# HDD installation?
PREP_HDD_INST='false'

# use only base image
BASE_IMAGE='false'

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "|                                                        |"
    echo "| Usage: ./untar_images_to_sdcard.sh                     |"
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
_temp="/tmp/untar_images_to_sdcard.$$"
_log="/tmp/untar_images_to_sdcard.log"

# check the args
while getopts 'hvmb:' opts 2>$_log
do
    case $opts in
        h) my_usage ;;
        v) print_version ;;
        b) BRAND=$OPTARG ;;
	m) BASE_IMAGE='true' ;;
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

    if [ "$PREP_HDD_INST" = 'true' ]; then
	if [[ ! -d "${SD_SHARED}" ]]; then
	    echo "ERROR -> ${SD_SHARED} not available!"
	    echo "         have you added them to your fstab? (see README.md)"
	    my_exit
	fi
    else
	if [[ ! -d "${SD_HOME}" ]]; then
	    echo "ERROR -> ${SD_HOME} not available!"
	    echo "         have you added them to your fstab? (see README.md)"
	    my_exit
	fi
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

    if [ "$PREP_HDD_INST" = 'true' ]; then
	mount $SD_SHARED
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not mount ${SD_SHARED}"
	    my_exit
	fi
    else
	mount $SD_HOME
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not mount ${SD_HOME}"
	    my_exit
	fi
    fi
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

    if [ "$PREP_HDD_INST" = 'true' ]; then
	umount $SD_SHARED
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not umount ${SD_SHARED}"
	    my_exit
	fi
    else
	umount $SD_HOME
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not umount ${SD_HOME}"
	    my_exit
	fi
    fi
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

case "$BRAND" in
    'bananapi')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
	SD_HOME=$BANANAPI_SDCARD_HOME
	SD_SHARED=$BANANAPI_SDCARD_SHARED
        ;;
    'bananapi-pro')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
	SD_HOME=$BANANAPI_SDCARD_HOME
	SD_SHARED=$BANANAPI_SDCARD_SHARED
        ;;
    'baalue')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
	SD_HOME=$BANANAPI_SDCARD_HOME
	SD_SHARED=$BANANAPI_SDCARD_SHARED
        ;;
    'olimex')
	SD_KERNEL=$OLIMEX_SDCARD_KERNEL
	SD_ROOTFS=$OLIMEX_SDCARD_ROOTFS
	SD_HOME=$OLIMEX_SDCARD_HOME
	SD_SHARED=$OLIMEX_SDCARD_SHARED
        ;;
    'cubietruck')
	SD_KERNEL=$CUBIETRUCK_SDCARD_KERNEL
	SD_ROOTFS=$CUBIETRUCK_SDCARD_ROOTFS
	SD_HOME=$CUBIETRUCK_SDCARD_HOME
	SD_SHARED=$CUBIETRUCK_SDCARD_SHARED
        ;;
    *)
        echo "ERROR -> ${BRAND} is not supported ... pls check"
        my_usage
esac

check_directories
mount_partitions

#
# the code
#


umount_partitions

cleanup
echo " "
echo "+------------------------------------------+"
echo "|             Cheers $USER                  "
echo "+------------------------------------------+"
echo " "
