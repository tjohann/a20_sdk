#!/usr/bin/env bash
################################################################################
#
# Title       :    install_kernel.sh
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
# Date/Beginn :    27.09.2016/07.09.2016
#
# Version     :    V2.00
#
# Milestones  :    V2.00 (sep 2016) -> update version info fo A20_SDK_V2.0.0
#                  V0.03 (sep 2016) -> fix a lot of bugs
#                  V0.02 (sep 2016) -> fix some bugs and add some smaller
#                                      improvements
#                                   -> first working version
#                  V0.01 (sep 2016) -> initial skeleton
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to install a build kernel to sdcard (see howto_kernel.txt)
#
################################################################################
#

# VERSION-NUMBER
VER='2.00'

# if env is sourced
MISSING_ENV='false'

# what to build
INSTALL_RT='false'
INSTALL_NONRT='false'

# which brand?
BRAND='none'

# mountpoints
SD_KERNEL='none'
SD_ROOTFS='none'

# program name
PROGRAM_NAME=${0##*/}

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ${PROGRAM_NAME} "
    echo "|        [-b] -> bananapi/bananapi-pro/olimex/baalue/    |"
    echo "|                cubietruck                              |"
    echo "|        [-r] -> install rt kernel parts                 |"
    echo "|        [-n] -> install non-rt kernel parts             |"
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
    umount_partitions
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
while getopts 'hvrnb:' opts 2>$_log
do
    case $opts in
	r) INSTALL_RT='true' ;;
	n) INSTALL_NONRT='true' ;;
	b) BRAND=$OPTARG ;;
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

# bananapi-{M1/Pro}/baalue
if [[ ! ${BANANAPI_SDCARD_KERNEL} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${BANANAPI_SDCARD_ROOTFS} ]]; then
    MISSING_ENV='true'
fi

# olimex
if [[ ! ${OLIMEX_SDCARD_KERNEL} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${OLIMEX_SDCARD_ROOTFS} ]]; then
    MISSING_ENV='true'
fi

# cubietruck
if [[ ! ${CUBIETRUCK_SDCARD_KERNEL} ]]; then
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

mount_partitions()
{
    mount $SD_KERNEL
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not mount ${SD_KERNEL}" >&2
	# do not exit -> will try to umount the others
    fi

    mount $SD_ROOTFS
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not mount ${SD_ROOTFS}" >&2
	# do not exit -> will try to umount the others
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
}

copy_kernel_folder()
{
    cp arch/arm/boot/dts/sun7i-a20-bananapi.dt[b,s] ${SD_KERNEL}/baalue
    if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not copy to ${SD_KERNEL}/baalue"
    fi

    cp arch/arm/boot/dts/sun7i-a20-bananapi.dt[b,s] ${SD_KERNEL}/bananapi
    if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not copy to ${SD_KERNEL}/bananapi"
    fi

    cp arch/arm/boot/dts/sun7i-a20-bananapro.dt[b,s] ${SD_KERNEL}/bananapi-pro
    if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not copy to ${SD_KERNEL}/bananapi-pro"
    fi

    cp arch/arm/boot/dts/sun7i-a20-olimex-som-evb.dt[b,s] ${SD_KERNEL}/olimex
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not copy to ${SD_KERNEL}/olimex"
    fi

    cp arch/arm/boot/dts/sun7i-a20-cubietruck.dt[b,s] ${SD_KERNEL}/cubietruck
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not copy to ${SD_KERNEL}/cubietruck"
    fi

    case "$BRAND" in
	'bananapi')
	    cp arch/arm/boot/dts/sun7i-a20-bananapi.dt[b,s] ${SD_KERNEL}
            ;;
	'bananapi-pro')
	    cp arch/arm/boot/dts/sun7i-a20-bananapro.dt[b,s] ${SD_KERNEL}
            ;;
	'baalue')
	    cp arch/arm/boot/dts/sun7i-a20-bananapi.dt[b,s] ${SD_KERNEL}
            ;;
	'olimex')
	    cp arch/arm/boot/dts/sun7i-a20-olimex-som-evb.dt[b,s] ${SD_KERNEL}
            ;;
	'cubietruck')
	    cp arch/arm/boot/dts/sun7i-a20-cubietruck.dt[b,s] ${SD_KERNEL}
            ;;
    esac
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not copy to ${SD_KERNEL}/cubietruck"
    fi

    cp arch/arm/boot/uImage ${SD_KERNEL}
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not copy arch/arm/boot/uImage ${SD_KERNEL}"
    fi

    cp .config ${SD_KERNEL}
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not copy to .config ${SD_KERNEL}"
    fi
}

copy_kernel()
{
    cp arch/arm/boot/uImage ${SD_KERNEL}/non-rt
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not copy arch/arm/boot/uImage ${SD_KERNEL}"
    fi

    cp .config ${SD_KERNEL}/non-rt
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not copy to .config ${SD_KERNEL}"
    fi
}

copy_kernel_rt()
{
    cp arch/arm/boot/uImage ${SD_KERNEL}/rt
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not copy arch/arm/boot/uImage ${SD_KERNEL}"
    fi

    cp .config ${SD_KERNEL}/rt
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not copy to .config ${SD_KERNEL}"
    fi
}

# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

echo " "
echo "+----------------------------------------+"
echo "|       install kernel to sdcard         |"
echo "| --> need sudo for some parts           |"
echo "+----------------------------------------+"
echo " "

sudo -v
# keep-alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

case "$BRAND" in
    'bananapi')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
        ;;
    'bananapi-pro')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
        ;;
    'baalue')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
        ;;
    'olimex')
	SD_KERNEL=$OLIMEX_SDCARD_KERNEL
	SD_ROOTFS=$OLIMEX_SDCARD_ROOTFS
        ;;
    'cubietruck')
	SD_KERNEL=$CUBIETRUCK_SDCARD_KERNEL
	SD_ROOTFS=$CUBIETRUCK_SDCARD_ROOTFS
        ;;
    *)
        echo "ERROR -> ${BRAND} is not supported ... pls check" >&2
        my_usage
esac

mount_partitions

if [ -d ${ARMHF_BIN_HOME}/kernel ]; then
    cd ${ARMHF_BIN_HOME}/kernel
else
    echo "ERROR -> ${ARMHF_BIN_HOME}/kernel not exists ... do a make init_sdk"
fi

if [ "$INSTALL_NONRT" = 'true' ]; then
    echo "install non-rt kernel"

    cd ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not change to linux-${ARMHF_KERNEL_VER}" >&2
        my_exit
    fi

    copy_kernel_folder
    copy_kernel

    make ARCH=arm clean
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not clean kernel folder" >&2
        my_exit
    fi

    cd ${ARMHF_BIN_HOME}/kernel
    sudo rsync -avz modules_${ARMHF_KERNEL_VER}/lib/modules/. ${SD_ROOTFS}/lib/modules/.
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not rsync -avc modules_${ARMHF_KERNEL_VER}/lib/modules/. ${SD_ROOTFS}/lib/modules/." >&2
        my_exit
    fi

    sudo rsync -avz --delete linux-${ARMHF_KERNEL_VER} ${SD_ROOTFS}/usr/src/.
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not  sudo rsync -av --delete linux-${ARMHF_KERNEL_VER} ${SD_ROOTFS}/usr/src/." >&2
        my_exit
    fi
fi

if [ "$INSTALL_RT" = 'true' ]; then
    echo "install rt kernel"

    cd ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}_rt
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not change to linux-${ARMHF_KERNEL_VER}_rt" >&2
        my_exit
    fi

    copy_kernel_folder
    copy_kernel_rt

    make ARCH=arm clean
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not clean kernel folder" >&2
        my_exit
    fi

    cd ${ARMHF_BIN_HOME}/kernel
    sudo rsync -avz modules_${ARMHF_RT_KERNEL_VER}_rt/lib/modules/. ${SD_ROOTFS}/lib/modules/.
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not rsync -avz modules_${ARMHF_RT_KERNEL_VER}_rt/lib/modules/. ${SD_ROOTFS}/lib/modules/." >&2
        my_exit
    fi

    sudo rsync -avz --delete linux-${ARMHF_KERNEL_VER}_rt ${SD_ROOTFS}/usr/src/.
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not rsync -avz --delete linux-${ARMHF_KERNEL_VER}_rt ${SD_ROOTFS}/usr/src/." >&2
        my_exit
    fi
fi

umount_partitions

cleanup
echo " "
echo "+----------------------------------------+"
echo "|            Cheers $USER "
echo "+----------------------------------------+"
echo " "
