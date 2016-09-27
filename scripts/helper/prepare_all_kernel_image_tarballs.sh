#!/usr/bin/env bash
################################################################################
#
# Title       :    prepare_all_kernel_image_tarballs.sh
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
# Date/Beginn :    27.09.2016/26.08.2016
#
# Version     :    V2.00
#
# Milestones  :    V2.00 (sep 2016) -> update version info fo A20_SDK_V2.0.0
#                  V0.03 (sep 2016) -> whitespaces
#                  V0.02 (aug 2016) -> first working version
#                  V0.01 (aug 2016) -> initial skeleton
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to prepare a tarball for all kernel images (based on
#   bananapi_kernel.tgz)
#
#   Workdir /opt/a20_sdk/images
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

# mountpoints
SD_KERNEL='none'

# ...
BRAND="bananapi"
HDD=''

# program name
PROGRAM_NAME=${0##*/}

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ${PROGRAM_NAME} "
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
    umount_partition

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
while getopts 'hv' opts 2>$_log
do
    case $opts in
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

if [[ ! ${BANANAPI_SDCARD_KERNEL} ]]; then
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

check_directory()
{
    if [[ ! -d "${SD_KERNEL}" ]]; then
	echo "ERROR -> ${SD_KERNEL} not available!" >&2
	echo "         have you added them to your fstab? (see README.md)" >&2
	my_exit
    fi
}

mount_partition()
{
    mount $SD_KERNEL
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not mount ${SD_KERNEL}" >&2
	my_exit
    fi
}

umount_partition()
{
    umount $SD_KERNEL
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not umount ${SD_KERNEL}" >&2
	# do not exit
    fi
}

untar_base_image()
{
    cd $SD_KERNEL
    tar xzvf ${ARMHF_BIN_HOME}/images/bananapi_kernel.tgz
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not untar ${ARMHF_BIN_HOME}/images/bananapi_kernel.tgz" >&2
	my_exit
    fi

    cd -
}

copy_rt()
{
    cp ${SD_KERNEL}/rt/* $SD_KERNEL
    cp ${SD_KERNEL}/rt/.config $SD_KERNEL
    cp ${SD_KERNEL}/${BRAND}/* $SD_KERNEL
}

copy_hdd()
{
    cp ${SD_KERNEL}/${BRAND}/hdd_boot/* $SD_KERNEL
}

copy_nonrt()
{
    cp ${SD_KERNEL}/non-rt/* $SD_KERNEL
    cp ${SD_KERNEL}/non-rt/.config $SD_KERNEL
    cp ${SD_KERNEL}/${BRAND}/* $SD_KERNEL
}

tar_image()
{
    cd $SD_KERNEL
    tar czvf ${ARMHF_BIN_HOME}/images/${BRAND}${HDD}_kernel.tgz .

    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not tar ${ARMHF_BIN_HOME}/images/${BRAND}${HDD}_kernel.tgz" >&2
	my_exit
    fi

    cd -
}

do_all_rt()
{
    rm -f sun7i-a20-*.dt?
    copy_rt
    copy_hdd
    tar_image
}

do_all_nonrt()
{
    rm -f sun7i-a20-*.dt?
    copy_nonrt
    copy_hdd
    tar_image
}

# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

echo " "
echo "+----------------------------------------+"
echo "|    create all kernel image tarballs    |"
echo "+----------------------------------------+"
echo " "

SD_KERNEL=$BANANAPI_SDCARD_KERNEL
check_directory
mount_partition
untar_base_image

#
# first all device with rt-preempt kernel (bananpi/olimex)
#

# bananapi -> only hdd image needed (bananapi_kernel.tgz is the base image)
BRAND="bananapi"
HDD="_hdd"
do_all_rt

# bananapi-pro
BRAND="bananapi-pro"
HDD=""
do_all_nonrt
HDD="_hdd"
do_all_nonrt

# baalue
BRAND="baalue"
HDD=""
do_all_nonrt
HDD="_hdd"
do_all_nonrt

# cubietruck
BRAND="cubietruck"
HDD=""
do_all_nonrt
HDD="_hdd"
do_all_nonrt

# olimex
BRAND="olimex"
HDD=""
do_all_rt
HDD="_hdd"
do_all_rt

umount_partition

cleanup
echo " "
echo "+----------------------------------------+"
echo "|            Cheers $USER "
echo "+----------------------------------------+"
echo " "
