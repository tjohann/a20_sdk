#!/usr/bin/env bash
################################################################################
#
# Title       :    brand_images.sh
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
# Date/Beginn :    02.07.2016/02.07.2016
#
# Version     :    V0.01
#
# Milestones  :    V0.01 (jul 2016) -> first functional version
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to brand installed image
#
# Some features
#   - ...
#
# Differences of the images (bananapi is the master!)
#   - written boodloader (dd if=...)
#   - *_SDCARD_KERNEL
#     - bootloader parts (SPL + cmd)
#     - all dts/dtb must be installed
#   - *_SDCARD_ROOTFS
#     - hostname
#     - dhcpd.conf
#     - hosts must include all devices
#     - change /etc/a20_sdk-release
#   - *_SDCARD_HOME
#     - should be similiar for all devices
#
# Differences to void-linux default image
# (https://repo.voidlinux.eu/live/current/void-cubieboard2-rootfs-XXXXX.tar.xz)
#   - change root password from voidlinux to root
#   - change kernel to mainline
#   (- change sdcard layout to (kernel/rootfs/home))
#   (- change fstab entry)
#
################################################################################
#

# VERSION-NUMBER
VER='0.01'

# if env is sourced
MISSING_ENV='false'

# which brand?
BRAND='none'

# mounted images
SD_KERNEL='none'
SD_ROOTFS='none'
SD_HOME='none'
SD_SHARED='none'

# source for branding
SRC_BRANDING='none'

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ./brand_images.sh                               |"
    echo "|        [-b] -> bananapi/bananapi-pro/olimex/cubietruck |"
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
    clear
    echo "+-----------------------------------+"
    echo "|          Cheers $USER            |"
    echo "+-----------------------------------+"
    cleanup
    exit
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
_temp="/tmp/brand_image.$$"
_log="/tmp/brand_image.log"


# check the args
while getopts 'hvb:' opts 2>$_log
do
    case $opts in
        h) my_usage ;;
        v) print_version ;;
        b) BRAND=$OPTARG ;;
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

# show a usage screen and exit
if [ "$MISSING_ENV" = 'true' ]; then
    cleanup
    clear
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

check_mounted_sdcard()
{
    #
    # Note: only check for one dir within the directory
    #

    if [[ "$SD_KERNEL" ]]; then
	if [ -d ${SD_KERNEL}/non-rt ]; then
            echo "$SD_KERNEL seems to be mounted"
	else
            echo "ERROR -> ${SD_KERNEL}/non-rt not available"
	    #my_usage
	fi
    else
	echo "ERROR -> image_mountpoint for kernel not set"
	#my_usage
    fi

    if [[ "$SD_ROOTFS" ]]; then
	if [ -d ${SD_ROOTFS}/etc ]; then
            echo "$SD_ROOTFS seems to be mounted"
	else
            echo "ERROR -> ${SD_ROOTFS}/etc not available"
	    #my_usage
	fi
    else
	echo "ERROR -> image_mountpoint for rootfs not set"
	#my_usage
    fi

    if [[ "$SD_HOME" ]]; then
	if [ -d ${SD_HOME}/baalue ]; then
            echo "$SD_HOME seems to be mounted"
	else
            echo "ERROR -> ${SD_HOME}/baalue not available"
	    #my_usage
	fi
    else
	echo "ERROR -> image_mountpoint for home not set"
	#my_usage
    fi

    #
    # TODO: usage of SHARED -> for hdd support
    #
    if [[ "$SD_SHARED" ]]; then
	if [ -d ${SD_SHARED}/lib/modules ]; then
            echo "$SD_SHARED seems to be mounted"
	else
            echo "ERROR -> ${SD_SHARED}/lib/modules not available"
	    # my_usage
	fi
    else
	echo "ERROR -> image_mountpoint for shared not set"
	# my_usage
    fi
}

brand_image()
{
    echo "brand_image with content of ${SRC_BRANDING}"

    SRC_BRANDING=${ARMHF_HOME}/${BRAND}/branding

    if [ -d ${SRC_BRANDING}/rootfs ]; then
	cd ${SD_ROOTFS}
	#rsync -av ${SRC_BRANDING}/rootfs/. .
    else
	echo "ERROR: no dir ${SRC_BRANDING}/rootfs"
    fi

    if [ -d ${SRC_BRANDING}/kernel ]; then
	cd ${SD_KERNEL}
	#rsync -av ${SRC_BRANDING}/kernel/. .
    else
	echo "ERROR: no dir ${SRC_BRANDING}/kernel"
    fi

    if [ -d ${SRC_BRANDING}/home ]; then
	cd ${SD_HOME}
	#rsync -av ${SRC_BRANDING}/kernel/. .
    else
	echo "ERROR: no dir ${SRC_BRANDING}/kernel"
    fi

    #
    # TODO: usage of SHARED -> for hdd support
    #
    if [ -d ${SRC_BRANDING}/shared ]; then
	cd ${SD_SHARED}
	#rsync -av ${SRC_BRANDING}/shared/. .
    else
	echo "ERROR: no dir ${SRC_BRANDING}/shared"
    fi
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

echo " "
echo "+----------------------------------------+"
echo "|    brand installed device image        |"
echo "+----------------------------------------+"
echo " "

case "$BRAND" in
    'bananapi')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
	SD_HOME=$BANANAPI_SDCARD_HOME
	SD_SHARED=$BANANAPI_SDCARD_SHARED
	check_mounted_sdcard
	brand_image
        ;;
    'bananapi-pro')
        SD_KERNEL=$BANANAPI_SDCARD_KERNEL
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
	SD_HOME=$BANANAPI_SDCARD_HOME
	SD_SHARED=$BANANAPI_SDCARD_SHARED
	check_mounted_sdcard
	brand_image
        ;;
    'olimex')
        SD_KERNEL=$OLIMEX_SDCARD_KERNEL
	SD_ROOTFS=$OLIMEX_SDCARD_ROOTFS
	SD_HOME=$OLIMEX_SDCARD_HOME
	SD_SHARED='none'
	check_mounted_sdcard
	brand_image
        ;;
    'cubietruck')
        SD_KERNEL=$CUBIETRUCK_SDCARD_KERNEL
	SD_ROOTFS=$CUBIETRUCK_SDCARD_ROOTFS
	SD_HOME=$CUBIETRUCK_SDCARD_HOME
	SD_SHARED=$CUBIETRUCK_SDCARD_SHARED
	check_mounted_sdcard
	brand_image
        ;;
    *)
        echo "ERROR -> ${BRAND} is not supported ... pls check"
        my_usage
esac



cleanup
echo " "
echo "+----------------------------------------+"
echo "|          Cheers $USER                |"
echo "+----------------------------------------+"
echo " "
