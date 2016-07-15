#!/usr/bin/env bash
################################################################################
#
# Title       :    get_image_tarballs.sh
#
# License:
#
# GPL
# (c) 2015-2016, thorsten.johannvorderbrueggen@t-online.de
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
# Date/Beginn :    15.07.2016/24.08.2015
#
# Version     :    V1.01
#
# Milestones  :    V1.01 (jul 2016) -> some smaller improvements/cleanups
#                  V1.00 (jul 2016) -> implement unified images download
#                  V0.13 (jul 2016) -> change exit code to 3
#                  V0.12 (jul 2016) -> some minor improvements
#                  V0.11 (jul 2016) -> some minor improvements
#                  V0.10 (apr 2016) -> add baalue
#                  V0.09 (apr 2016) -> add cubietruck-hdd
#                                      add bananapi-pro-hdd
#                                      remove unused comment
#                                      fix wrong image names
#                  V0.08 (apr 2016) -> create $ARMHF_BIN_HOME/* if it not exist
#                  V0.07 (apr 2016) -> check for architecture
#                                      some more error checks/cleanups
#                  V0.06 (mar 2016) -> add missing check for dir
#                  V0.05 (jan 2016) -> implement new architecture
#                  V0.04 (jan 2016) -> add bananapi-pro as device
#                  V0.03 (jan 2016) -> fix missing help content
#                  V0.02 (jan 2016) -> adapt for usage in a20_sdk
#                                      add support for olimex
#                                      add support for cubietruck
#                  V0.01 (aug 2015) -> first functional version
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to download the image tarballs
#
# Some features
#   - ...
#
# Notes
#   - Images reside on sourceforge with the following structure
#     "root on sf"
#     -> .
#         "device specific kernel images":
#         -> bananapi/bananapi_kernel.tgz
#         -> ...
#         -> olimex/olmex_kernel.tgz
#         "common parts for all images":
#         -> common
#                  -> a20_sdk_rootfs.tgz
#                  -> a20_sdk_home.tgz
#                  -> a20_sdk_base_rootfs.tgz
#         -> toolchain*.tgz
#         -> host_*.tgz
#         -> checksum.sha256
#         -> README.txt
#
################################################################################
#

# VERSION-NUMBER
VER='1.00'

# if env is sourced
MISSING_ENV='false'

# which brand?
BRAND='none'

# to download
DOWNLOAD_IMAGE='none'

# use only base image
BASE_IMAGE='none'

# HDD installation?
PREP_HDD_INST='none'

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ./get_image_tarballs.sh                         |"
    echo "|        [-v] -> print version info                      |"
    echo "|        [-h] -> this help                               |"
    echo "|        [-b] -> bananapi/bananapi-pro/olimex/baalue/    |"
    echo "|                cubietruck                              |"
    echo "|        [-m] -> download the minimal images             |"
    echo "|        [-s] -> download images for hdd installation    |"
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
_temp="/tmp/get_image_tarballs.$$"
_log="/tmp/get_image_tarballs.log"


# check the args
while getopts 'hvmsb:' opts 2>$_log
do
    case $opts in
	b) BRAND=$OPTARG ;;
	s) PREP_HDD_INST='true' ;;
	m) BASE_IMAGE='true' ;;
        h) my_usage ;;
	v) print_version ;;
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

# --- download a tarballs from sf
get_tarball()
{
    echo "INFO: try to download ${DOWNLOAD_IMAGE}"

    local download_file=`echo ${DOWNLOAD_IMAGE} | awk -F '[/]' '{print $(NF-0)}'`
    if [ -f ${download_file} ]; then
	echo "${DOWNLOAD_IMAGE} already exist -> do nothing"
    else
	wget $DOWNLOAD_IMAGE
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not download ${DOWNLOAD_IMAGE}"
	    my_exit
	fi
    fi

    DOWNLOAD_IMAGE='none'
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

echo " "
echo "+----------------------------------------------+"
echo "|  dowload latest image tarballs               |"
echo "+----------------------------------------------+"
echo " "

if [ -d ${ARMHF_BIN_HOME}/images ]; then
    cd ${ARMHF_BIN_HOME}/images
else
    mkdir -p ${ARMHF_BIN_HOME}/images
    if [ $? -ne 0 ] ; then
	echo "ERROR -> mkdir -p ${ARMHF_BIN_HOME}/images"
	my_exit
    fi
    cd ${ARMHF_BIN_HOME}/images
fi

case "$BRAND" in
    'bananapi')
	DOWNLOAD_IMAGE="http://sourceforge.net/projects/a20devices/files/bananapi/bananapi_kernel.tgz"
	get_tarball
        ;;
    'bananapi-pro')
	DOWNLOAD_IMAGE="http://sourceforge.net/projects/a20devices/files/bananapi/bananapi-pro_kernel.tgz"
	get_tarball
        ;;
    'baalue')
	 DOWNLOAD_IMAGE="http://sourceforge.net/projects/a20devices/files/bananapi/baalue_kernel.tgz"
	get_tarball
        ;;
    'olimex')
	DOWNLOAD_IMAGE="http://sourceforge.net/projects/a20devices/files/olimex/olimex_kernel.tgz"
	get_tarball
        ;;
    'cubietruck')
	DOWNLOAD_IMAGE="http://sourceforge.net/projects/a20devices/files/cubietruck/cubietruck_kernel.tgz"
	get_tarball
        ;;
    *)
        echo "ERROR -> ${BRAND} is not supported ... pls check"
        my_usage
esac

# download common rootfs (base or full)
if [ "$BASE_IMAGE" = 'true' ]; then
    DOWNLOAD_IMAGE="http://sourceforge.net/projects/a20devices/files/common/a20_sdk_base_rootfs.tgz"
else
    DOWNLOAD_IMAGE="http://sourceforge.net/projects/a20devices/files/common/a20_sdk_rootfs.tgz"
fi
get_tarball

# download common home
DOWNLOAD_IMAGE="http://sourceforge.net/projects/a20devices/files/common/a20_sdk_home.tgz"
get_tarball

# download base rootfs if needed
if [ "$PREP_HDD_INST" = 'true' ]; then
    DOWNLOAD_IMAGE="http://sourceforge.net/projects/a20devices/files/common/a20_sdk_base_rootfs.tgz"
fi

cleanup
echo " "
echo "+----------------------------------------+"
echo "|            Cheers $USER"
echo "+----------------------------------------+"
echo " "
