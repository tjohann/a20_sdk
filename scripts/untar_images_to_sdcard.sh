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
# Date/Beginn :    27.09.2016/15.07.2016
#
# Version     :    V2.00
#
# Milestones  :    V2.00 (sep 2016) -> update version info fo A20_SDK_V2.0.0
#                  V1.07 (aug 2016) -> remove dot from untar kdo (not needed)
#                  V1.06 (aug 2016) -> whitespaces
#                  V1.05 (aug 2016) -> sudo handling at beginning
#                  V1.04 (aug 2016) -> add hdd-only-sdcard parts
#                  V1.03 (aug 2016) -> some smaller fixes
#                  V1.02 (aug 2016) -> be aware of hdd installation
#                  V1.01 (aug 2016) -> add features of make_sdcard.sh
#                  V1.00 (jul 2016) -> version bump
#                                   -> some minor updates
#                  V0.04 (jul 2016) -> relax unmount function error handling
#                  V0.03 (jul 2016) -> redirect errors to >&2
#                  V0.02 (jul 2016) -> first content
#                  V0.01 (jul 2016) -> initial version
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

# HDD installation?
PREP_HDD_INST='false'

# HDD-boot only sd-card?
HDD_BOOT_SDCARD='false'

# use only base image
BASE_IMAGE='false'

# program name
PROGRAM_NAME=${0##*/}

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "|                                                        |"
    echo "| Usage: ${PROGRAM_NAME} "
    echo "|        [-b] -> bananapi/bananapi-pro/olimex/baalue/    |"
    echo "|                cubietruck                              |"
    echo "|        [-m] -> use the minimal images                  |"
    echo "|        [-s] -> prepare images for hdd installation     |"
    echo "|        [-e] -> prepare partitions for hdd-boot-only    |"
    echo "|                -e AND -s wont make sense -> -e rules   |"
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
while getopts 'hvsemb:' opts 2>$_log
do
    case $opts in
        h) my_usage ;;
        v) print_version ;;
        b) BRAND=$OPTARG ;;
	m) BASE_IMAGE='true' ;;
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

check_tarballs()
{
    if [ "$HDD_BOOT_SDCARD" = 'true' ]; then
	if [[ ! -f "${ARMHF_BIN_HOME}/images/${BRAND}_hdd_kernel.tgz" ]]; then
	    echo "ERROR -> ${ARMHF_BIN_HOME}/images/${BRAND}_hdd_kernel.tgz not available!" >&2
	    my_exit
	fi
    else
	if [[ ! -f "${ARMHF_BIN_HOME}/images/${BRAND}_kernel.tgz" ]]; then
	    echo "ERROR -> ${ARMHF_BIN_HOME}/images/${BRAND}_kernel.tgz not available!" >&2
	    my_exit
	fi

	if [ "$BASE_IMAGE" = 'true' ]; then
	    if [[ ! -f "${ARMHF_BIN_HOME}/images/a20_sdk_base_rootfs.tgz" ]]; then
		echo "ERROR -> ${ARMHF_BIN_HOME}/images/a20_sdk_base_rootfs.tgz not available!" >&2
		my_exit
	    fi
	else
	    if [[ ! -f "${ARMHF_BIN_HOME}/images/a20_sdk_rootfs.tgz" ]]; then
		echo "ERROR -> ${ARMHF_BIN_HOME}/images/a20_sdk_rootfs.tgz not available!" >&2
		my_exit
	    fi
	fi

	if [ "$PREP_HDD_INST" = 'true' ]; then
	    echo "prepare hdd installation -> no home tarball needed"
	else
	    if [[ ! -f "${ARMHF_BIN_HOME}/images/a20_sdk_home.tgz" ]]; then
		echo "ERROR -> ${ARMHF_BIN_HOME}/images/a20_sdk_home.tgz not available!" >&2
		my_exit
	    fi
	fi
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

untar_images()
{
    if [ "$HDD_BOOT_SDCARD" = 'true' ]; then
	echo "No need to untar all tarballs"

	cd $SD_KERNEL
	sudo tar xzpvf ${ARMHF_BIN_HOME}/images/${BRAND}_hdd_kernel.tgz
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not untar ${ARMHF_BIN_HOME}/images/${BRAND}_hdd_kernel.tgz" >&2
	    my_exit
	fi
    else
	cd $SD_KERNEL
	sudo tar xzpvf ${ARMHF_BIN_HOME}/images/${BRAND}_kernel.tgz
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not untar ${ARMHF_BIN_HOME}/images/${BRAND}_kernel.tgz" >&2
	    my_exit
	fi

	cd $SD_ROOTFS
	if [ "$BASE_IMAGE" = 'true' ]; then
	    sudo tar xzpvf ${ARMHF_BIN_HOME}/images/a20_sdk_base_rootfs.tgz
	else
	    sudo tar xzpvf ${ARMHF_BIN_HOME}/images/a20_sdk_rootfs.tgz
	fi
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not untar ${ARMHF_BIN_HOME}/images/a20_sdk_*rootfs.tgz" >&2
	    my_exit
	fi

	if [ "$PREP_HDD_INST" = 'true' ]; then
	    cd $SD_SHARED
	    echo "copy all needed files to $SD_SHARED"

	    sudo cp ${ARMHF_BIN_HOME}/images/a20_sdk_home.tgz .
	    sudo cp ${ARMHF_BIN_HOME}/images/${BRAND}_kernel.tgz .
	    if [ "$BASE_IMAGE" = 'true' ]; then
		sudo cp ${ARMHF_BIN_HOME}/images/a20_sdk_base_rootfs.tgz .
	    else
		sudo cp ${ARMHF_BIN_HOME}/images/a20_sdk_rootfs.tgz .
	    fi
	    # check only once -> check_directory and check_tarballs do it first
	    if [ $? -ne 0 ] ; then
		echo "ERROR -> could not copy tarballs to ${SD_SHARED}" >&2
		my_exit
	    fi
	else
	    cd $SD_HOME
	    sudo tar xzpvf ${ARMHF_BIN_HOME}/images/a20_sdk_home.tgz
	fi
    fi

    cd ${HOME}
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

# sudo handling up-front
echo " "
echo "+------------------------------------------+"
echo "| untar images to sd-card                  |"
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
        echo "ERROR -> ${BRAND} is not supported ... pls check" >&2
        my_usage
esac

check_directories
check_tarballs
mount_partitions

untar_images
sync

umount_partitions

cleanup
echo " "
echo "+------------------------------------------+"
echo "|             Cheers $USER                  "
echo "+------------------------------------------+"
echo " "
