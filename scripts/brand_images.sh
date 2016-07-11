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
# Date/Beginn :    11.07.2016/02.07.2016
#
# Version     :    V0.04
#
# Milestones  :    V0.04 (jul 2016) -> split branding into different dir
#                                      add support for baalue
#                                      change exit code to 3
#                  V0.03 (jul 2016) -> some fixes and improvements
#                  V0.02 (jul 2016) -> first working version
#                  V0.01 (jul 2016) -> initial skeleton
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
#   - *_SDCARD_ROOTFS
#     - hostname
#     - dhcpd.conf
#
################################################################################
#

# VERSION-NUMBER
VER='0.04'

# if env is sourced
MISSING_ENV='false'

# which brand?
BRAND='none'

# mounted images
SD_ROOTFS='none'
SD_SHARED='none'

# source for branding
SRC_BRANDING='none'

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ./brand_images.sh                               |"
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

if [[ ! ${BANANAPI_SDCARD_ROOTFS} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${OLIMEX_SDCARD_ROOTFS} ]]; then
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

brand_image_etc()
{
    local src_branding=${ARMHF_HOME}/${BRAND}/branding/etc

    if [ -d ${src_branding} ]; then
	if [[ ! -d "${SD_ROOTFS}" ]]; then
	    echo "ERROR -> ${SD_ROOTFS} not available!"
	    echo "         have you added them to your fstab? (see README.md)"
	    my_usage
	fi

	mountpoint $SD_ROOTFS
	if [ $? -ne 0 ] ; then
	    echo "${SD_ROOTFS} not mounted, i try it now"
	    mount $SD_ROOTFS
	    if [ $? -ne 0 ] ; then
		echo "ERROR -> could not mount ${SD_ROOTFS}"
		my_exit
	    fi
	fi

	if [[ ! -d "${SD_ROOTFS}/etc" ]]; then
	    echo "ERROR -> ${SD_ROOTFS}/etc not available ... abort now!"
	    my_exit
	fi

	echo "sudo rsync -av ${src_branding}/. ${SD_ROOTFS}/etc/."
	sudo rsync -av ${src_branding}/. ${SD_ROOTFS}/etc/.
    else
	echo "INFO: no dir ${src_branding}, so no branding for ${BRAND}"
    fi
}

brand_image_home()
{
    local src_branding=${ARMHF_HOME}/${BRAND}/branding/home

    if [ -d ${src_branding} ]; then
	if [[ ! -d "${SD_HOME}" ]]; then
	    echo "ERROR -> ${SD_HOME} not available!"
	    echo "         have you added them to your fstab? (see README.md)"
	    my_usage
	fi

	mountpoint $SD_HOME
	if [ $? -ne 0 ] ; then
	    echo "${SD_HOME} not mounted, i try it now"
	    mount $SD_HOME
	    if [ $? -ne 0 ] ; then
		echo "ERROR -> could not mount ${SD_HOME}"
		my_exit
	    fi
	fi

	if [[ ! -d "${SD_HOME}/baalue" ]]; then
	    echo "ERROR -> ${SD_ROOTFS}/baalue not available ... abort now!"
	    my_exit
	fi

	echo "sudo rsync -av ${src_branding}/. ${SD_HOME}/baalue/."
	sudo rsync -av ${src_branding}/. ${SD_HOME}/baalue/.
    else
	echo "INFO: no dir ${src_branding}, so no branding for ${BRAND}"
    fi
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

echo " "
echo "+----------------------------------------+"
echo "| brand installed device image           |"
echo "| --> prepare your password for sudo     |"
echo "+----------------------------------------+"
echo " "

case "$BRAND" in
    'bananapi')
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
	brand_image_etc
	brand_image_home()
        ;;
    'bananapi-pro')
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
	brand_image_etc
	brand_image_home()
        ;;
    'baalue')
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
	brand_image_etc
	brand_image_home()
        ;;
    'olimex')
	SD_ROOTFS=$OLIMEX_SDCARD_ROOTFS
	brand_image_etc
	brand_image_home()
        ;;
    'cubietruck')
	SD_ROOTFS=$CUBIETRUCK_SDCARD_ROOTFS
	brand_image_etc
	brand_image_home()
        ;;
    *)
        echo "ERROR -> ${BRAND} is not supported ... pls check"
        my_usage
esac

cleanup
echo " "
echo "+----------------------------------------+"
echo "|            Cheers $USER "
echo "+----------------------------------------+"
echo " "
