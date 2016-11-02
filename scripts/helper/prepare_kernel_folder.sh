#!/usr/bin/env bash
################################################################################
#
# Title       :    prepare_kernel_folder.sh
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
# Date/Beginn :    02.11.2016/07.09.2016
#
# Version     :    V2.01
#
# Milestones  :    V2.01 (nov 2016) -> add support for nanopi-neo
#                  V2.00 (sep 2016) -> update version info fo A20_SDK_V2.0.0
#                  V0.01 (sep 2016) -> initial skeleton
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to prepare a kernel folder as base for install to sdcard.sh
#
################################################################################
#

# VERSION-NUMBER
VER='2.01'

# if env is sourced
MISSING_ENV='false'

# what to build
PREPARE_RT='false'
PREPARE_NONRT='false'

# program name
PROGRAM_NAME=${0##*/}

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ${PROGRAM_NAME} "
    echo "|        [-r] -> prepare rt kernel folder                |"
    echo "|        [-n] -> prepare non-rt kernel folder            |"
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
while getopts 'hvrn' opts 2>$_log
do
    case $opts in
	r) PREPARE_RT='true' ;;
	n) PREPARE_NONRT='true' ;;
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
    exit
fi


# ******************************************************************************
# ***                      The functions for main_menu                       ***
# ******************************************************************************



# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

echo " "
echo "+----------------------------------------+"
echo "|       prepare share kernel folder      |"
echo "+----------------------------------------+"
echo " "

if [ -d ${ARMHF_BIN_HOME}/kernel ]; then
    cd ${ARMHF_BIN_HOME}/kernel
else
    echo "ERROR -> ${ARMHF_BIN_HOME}/kernel not exists"
fi

if [ "$PREPARE_NONRT" = 'true' ]; then
    echo "prepare non-rt kernel folder"

    if [ -d ${ARMHF_BIN_HOME}/kernel/kernel_${ARMHF_KERNEL_VER} ]; then
	echo "folder kernel_${ARMHF_KERNEL_VER} exists -> remove it"
	rm -rf kernel_${ARMHF_KERNEL_VER}
    fi

    mkdir kernel_${ARMHF_KERNEL_VER}
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not mkdir kernel_${ARMHF_KERNEL_VER}" >&2
        my_exit
    fi

    cd ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not mkdir kernel_${ARMHF_KERNEL_VER}" >&2
        my_exit
    fi

    cp arch/arm/boot/dts/sun7i-a20-bananapi.dt[b,s] ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}
    cp arch/arm/boot/dts/sun7i-a20-bananapro.dt[b,s] ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}
    cp arch/arm/boot/dts/sun7i-a20-olimex-som-evb.dt[b,s] ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}
    cp arch/arm/boot/dts/sun7i-a20-cubietruck.dt[b,s] ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}
    cp arch/arm/boot/dts/sun8i-h3-nanopi-neo.dt[b,s] ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}

    cp arch/arm/boot/uImage ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}
    cp .config ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}

    make ARCH=arm clean
fi

if [ "$PREPARE_RT" = 'true' ]; then
    echo "prepare rt kernel folder"

    if [ -d ${ARMHF_BIN_HOME}/kernel/kernel_${ARMHF_KERNEL_VER}_rt ]; then
	echo "folder kernel_${ARMHF_KERNEL_VER} exists -> remove it"
	rm -rf kernel_${ARMHF_KERNEL_VER}_rt
    fi

    mkdir kernel_${ARMHF_KERNEL_VER}_rt
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not mkdir kernel_${ARMHF_KERNEL_VER}_rt" >&2
        my_exit
    fi

    cd ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_RT_KERNEL_VER}_rt
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not mkdir kernel_${ARMHF_KERNEL_VER}_rt" >&2
        my_exit
    fi

    cp arch/arm/boot/dts/sun7i-a20-bananapi.dt[b,s] ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}_rt
    cp arch/arm/boot/dts/sun7i-a20-bananapro.dt[b,s] ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}_rt
    cp arch/arm/boot/dts/sun7i-a20-olimex-som-evb.dt[b,s] ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}_rt
    cp arch/arm/boot/dts/sun7i-a20-cubietruck.dt[b,s] ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}_rt
    cp arch/arm/boot/dts/sun8i-h3-nanopi-neo.dt[b,s] ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}_rt

    cp arch/arm/boot/uImage ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}_rt
    cp .config ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}_rt

    make ARCH=arm clean
fi

cleanup
echo " "
echo "+----------------------------------------+"
echo "|            Cheers $USER "
echo "+----------------------------------------+"
echo " "
