#!/usr/bin/env bash
################################################################################
#
# Title       :    install_uboot.sh
#
# License:
#
# GPL
# (c) 2016-2020, thorsten.johannvorderbrueggen@t-online.de
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
# Date/Beginn :    02.07.2020/02.12.2016
#
# Version     :    V2.02
#
# Milestones  :    V2.02 (jul 2020) -> add support for orangepi-zero
#                  V2.01 (apr 2020) -> add support for bananapi-m3
#                  V2.00 (aug 2017) -> add support for cubietruck-plus
#                                      version bump to V2.00
#                  V0.04 (jul 2017) -> add baalue as device
#                  V0.03 (feb 2017) -> some smaller changes
#                  V0.02 (jan 2017) -> fix kdo argument handling
#                  V0.01 (dec 2016) -> initial version
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to install u-boot (see howto_uboot.txt)
#
# Notes
#   ...
#
################################################################################
#

# VERSION-NUMBER
VER='2.02'

# if env is sourced
MISSING_ENV='false'

# which brand?
BRAND='none'

# copy uboot also to repo? -> for maintainer
COPY_UBOOT_TO_REPO='false'


# program name
PROGRAM_NAME=${0##*/}

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ${PROGRAM_NAME} "
    echo "|        [-b] -> bananapi/bananapi-pro/olimex/baalue/    |"
    echo "|                cubietruck/cubietruck-plus/nanopi/      |"
    echo "|                bananapi-m3/orangepi-zero               |"
    echo "|        [-r] -> copy bin file to repo (for maintainer)  |"
    echo "|        [-v] -> print version info                      |"
    echo "|        [-h] -> this help                               |"
    echo "|                                                        |"
    echo "| Note: to WRITE the bootloader to sd-card, pls use the  |"
    echo "|       script write_bootloader.sh!                      |"
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
    echo " "
    echo "+----------------------------------------+"
    echo "|          Cheers $USER            "
    echo "+----------------------------------------+"
    echo " "
    umount_partition
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
while getopts 'hvrb:' opts 2>$_log
do
    case $opts in
	b) BRAND=$OPTARG ;;
	r) COPY_UBOOT_TO_REPO='true' ;;
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

if [[ ! ${BANANAPI_SDCARD_KERNEL} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${OLIMEX_SDCARD_KERNEL} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${CUBIETRUCK_SDCARD_KERNEL} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${NANOPI_SDCARD_KERNEL} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${ORANGEPI_SDCARD_KERNEL} ]]; then
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

check_uboot_repo()
{
    if [[ ! -d "${REPO_PATH}" ]]; then
	echo "ERROR -> ${repo_name} not available" >&2
	my_exit
    fi

    if [[ ! -f "${REPO_PATH}/u-boot-sunxi-with-spl.bin" ]]; then
	echo "ERROR -> ${REPO_PATH}/u-boot-sunxi-with-spl.bin not available" >&2
	my_exit
    fi
}

mount_partition()
{
    mount $SD_KERNEL
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not mount ${SD_KERNEL}" >&2
	# do not exit -> will try to umount the others
    fi
}

umount_partition()
{
    umount $SD_KERNEL
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not umount ${SD_KERNEL}" >&2
	# ignore error
    fi
}

copy_uboot_to_sdcard()
{
    echo "copy_uboot_to_sdcard"

    # not really needed
    cp ${REPO_PATH}/u-boot-sunxi-with-spl.bin ${SD_KERNEL}/${BRAND}

    cp ${REPO_PATH}/u-boot-sunxi-with-spl.bin ${SD_KERNEL}/
    if [ $? -ne 0 ]; then
	echo "ERROR: could not copy uboot to ${SD_KERNEL}" >&2
	my_exit
    fi
}

copy_uboot_to_repo()
{
    echo "copy_uboot_to_repo"

    cp ${REPO_PATH}/u-boot-sunxi-with-spl.bin ${ARMHF_HOME}/${BRAND}/u-boot
    if [ $? -ne 0 ]; then
	echo "ERROR: could not copy uboot to ${ARMHF_HOME}/${BRAND}/u-boot" >&2
	my_exit
    fi
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

if [ $BRAND = 'none' ]; then
    echo "no target device selected -> $BRAND"
    my_exit
else
    echo " "
    echo "+----------------------------------------+"
    echo "| build bootloader for $BRAND "
    echo "+----------------------------------------+"
    echo " "
fi

case "$BRAND" in
    'baalue')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
        ;;
    'bananapi')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
        ;;
    'bananapi-pro')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
        ;;
    'bananapi-m3')
	SD_KERNEL=$BANANAPI_SDCARD_KERNEL
        ;;
    'olimex')
	SD_KERNEL=$OLIMEX_SDCARD_KERNEL
        ;;
    'cubietruck')
	SD_KERNEL=$CUBIETRUCK_SDCARD_KERNEL
        ;;
    'cubietruck-plus')
	SD_KERNEL=$CUBIETRUCK_SDCARD_KERNEL
        ;;
    'nanopi')
	SD_KERNEL=$NANOPI_SDCARD_KERNEL
        ;;
    'orangepi-zero')
	SD_KERNEL=$ORANGEPI_SDCARD_KERNEL
        ;;
    *)
        echo "ERROR -> ${BRAND} is not supported ... pls check" >&2
        my_exit
esac

REPO_PATH="${ARMHF_BIN_HOME}/external/u-boot"
check_uboot_repo
check_directory

mount_partition
copy_uboot_to_sdcard

if [ $COPY_UBOOT_TO_REPO = 'true' ]; then
    echo "copy uboot also to repo"
    copy_uboot_to_repo
fi

umount_partition

cleanup
echo " "
echo "+----------------------------------------+"
echo "|            Cheers $USER "
echo "+----------------------------------------+"
echo " "
