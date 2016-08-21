#!/usr/bin/env bash
################################################################################
#
# Title       :    brand_baalue_images.sh
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
# Date/Beginn :    21.08.2016/21.08.2016
#
# Version     :    V0.01
#
# Milestones  :    V0.01 (jul 2016) -> initial skeleton
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to brand the base baalue images
#
# Some features
#   - ...
#
# Differences of the images (bananapi is the master!)
#   - *_SDCARD_ROOTFS
#     - hostname
#     - dhcpd.conf
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
SD_ROOTFS='none'
SD_HOME='none'
SD_SHARED='none'

# HDD installation?
PREP_HDD_INST='false'

# Node (0 ... 9, master, slave)
NODE='none'

# program name
PROGRAM_NAME=${0##*/}

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ${PROGRAM_NAME} "
    echo "|        [-b] -> bananapi/cubietruck                     |"
    echo "|        [-n] -> node (0...9, master, slave)             |"
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
while getopts 'hvsb:n:' opts 2>$_log
do
    case $opts in
        h) my_usage ;;
        v) print_version ;;
        b) BRAND=$OPTARG ;;
	b) NODE=$OPTARG ;;
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

if [[ ! ${BANANAPI_SDCARD_ROOTFS} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${CUBIETRUCK_SDCARD_ROOTFS} ]]; then
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

umount_partitions()
{
    umount $SD_ROOTFS
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not umount ${SD_ROOTFS}" >&2
    fi

    if [ "$PREP_HDD_INST" = 'true' ]; then
	umount $SD_SHARED
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not umount ${SD_HOME}" >&2
	fi
    else
	umount $SD_HOME
	if [ $? -ne 0 ] ; then
	    echo "INFO -> could not umount ${SD_HOME}" >&2
	fi
    fi
}

brand_image_etc()
{
    local src_branding=${ARMHF_HOME}/baalue/${BRAND}/etc_${NODE}/

    if [ -d ${src_branding} ]; then
	if [[ ! -d "${SD_ROOTFS}" ]]; then
	    echo "ERROR -> ${SD_ROOTFS} not available!" >&2
	    echo "         have you added them to your fstab? (see README.md)" >&2
	    my_usage
	fi

	mountpoint $SD_ROOTFS
	if [ $? -ne 0 ] ; then
	    echo "${SD_ROOTFS} not mounted, i try it now"
	    mount $SD_ROOTFS
	    if [ $? -ne 0 ] ; then
		echo "ERROR -> could not mount ${SD_ROOTFS}" >&2
		my_exit
	    fi
	fi

	if [[ ! -d "${SD_ROOTFS}/etc" ]]; then
	    echo "ERROR -> ${SD_ROOTFS}/etc not available ... abort now!" >&2
	    my_exit
	fi

	echo "sudo rsync -av ${src_branding}/. ${SD_ROOTFS}/etc/."
	sudo rsync -av ${src_branding}/. ${SD_ROOTFS}/etc/.
    else
	echo "INFO: no dir ${src_branding}, so no branding for ${BRAND}"
    fi
}

brand_image_shared()
{
    echo "some content needed"
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

# sudo handling up-front
echo " "
echo "+------------------------------------------+"
echo "| brand baalue specific images             |"
echo "| --> need sudo for some parts             |"
echo "+------------------------------------------+"
echo " "

sudo -v
# keep-alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

case "$BRAND" in
    'bananapi')
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
	SD_HOME=$BANANAPI_SDCARD_HOME
	SD_SHARED=$BANANAPI_SDCARD_SHARED
        ;;
    'cubietruck')
	SD_ROOTFS=$CUBIETRUCK_SDCARD_ROOTFS
	SD_HOME=$CUBIETRUCK_SDCARD_HOME
	SD_SHARED=$CUBIETRUCK_SDCARD_SHARED
        ;;
    *)
        echo "ERROR -> ${BRAND} is not supported ... pls check" >&2
        my_usage
esac

brand_image_etc
if [ "$PREP_HDD_INST" = 'true' ]; then
    brand_image_shared
else
    brand_image_home
fi

umount_partitions

cleanup
echo " "
echo "+----------------------------------------+"
echo "|            Cheers $USER "
echo "+----------------------------------------+"
echo " "
