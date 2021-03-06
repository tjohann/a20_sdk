#!/usr/bin/env bash
################################################################################
#
# Title       :    build_kernel.sh
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
# Date/Beginn :    02.07.2020/07.09.2016
#
# Version     :    V2.07
#
# Milestones  :    V2.07 (jul 2020) -> add support for orangepi-zero
#                  V2.06 (jun 2020) -> fix dts copy bug
#                  V2.05 (apr 2020) -> add support for bananapi-m3
#                  V2.04 (aug 2017) -> add support for cubietruck-plus
#                  V2.03 (apr 2017) -> be aware of MY_HOST_ARCH
#                                      some smaller improvements
#                  V2.02 (dec 2016) -> fix kdo handling
#                                      add check for cross-compiler
#                  V2.01 (nov 2016) -> add support for nanopi neo
#                  V2.00 (sep 2016) -> update version info fo A20_SDK_V2.0.0
#                                      fix PWD handling
#                  V0.03 (sep 2016) -> fix some bugs
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
#   A simple tool to build do a standard kernel build (see howto_kernel.txt)
#
# Notes
#   - as always the bananapi is the "lead" device
#   - build non-rt kernel (see kdo argument)
#   - build rt kernel (see kdo argument)
#   - install modules to ${ARMHF_BIN_HOME}
#
#   -> to install it on a device use helpers/install_kernel.sh
#
################################################################################
#

# VERSION-NUMBER
VER='2.07'

# if env is sourced
MISSING_ENV='false'

# what to build
BUILD_RT='false'
BUILD_NONRT='false'

# program name
PROGRAM_NAME=${0##*/}

# number of physical cores
NUM_CORES=$(getconf _NPROCESSORS_ONLN)

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ${PROGRAM_NAME} "
    echo "|        [-r] -> build only rt kernel parts              |"
    echo "|        [-n] -> build only non-rt kernel parts          |"
    echo "|        [-a] -> build all parts                         |"
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
while getopts 'hvrna' opts 2>$_log
do
    case $opts in
	r) BUILD_RT='true' ;;
	n) BUILD_NONRT='true' ;;
	a) BUILD_RT='true'
	   BUILD_NONRT='true'
	   ;;
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
# ***                     Check for correct architecture                     ***
# ******************************************************************************

if [ "$MY_HOST_ARCH" = 'x86_64' ]; then
    USED_CMD="arm-none-linux-gnueabihf-gcc"
else
    USED_CMD="gcc"
fi

for cmd in ${USED_CMD} ; do
    if ! [ -x "$(command -v ${cmd})" ]; then
#	cleanup
	echo " "
	echo "+------------------------------------------------+"
	echo "|                                                |"
	echo "| ERROR: $cmd is missing |"
	echo "|                                                |"
	echo "+------------------------------------------------+"
	echo " "
	exit
    else
	echo "Note: $cmd is available"
    fi
done


# ******************************************************************************
# ***                      The functions for main_menu                       ***
# ******************************************************************************

check_tarballs()
{
    if [ "$BUILD_NONRT" = 'true' ]; then
	if [[ ! -f "${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}.tar.xz" ]]; then
	    echo "ERROR -> ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}.tar.xz not available!" >&2
	    my_exit
	fi
    fi

    if [ "$BUILD_RT" = 'true' ]; then
	if [[ ! -f "${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_RT_KERNEL_VER}.tar.xz" ]]; then
	    echo "ERROR -> ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_RT_KERNEL_VER}.tar.xz not available!" >&2
	    my_exit
	fi

	if [[ ! -f "${ARMHF_BIN_HOME}/kernel/patch-${ARMHF_RT_KERNEL_VER}-${ARMHF_RT_VER}.patch.gz" ]]; then
	    echo "ERROR -> ${ARMHF_BIN_HOME}/kernel/patch-${ARMHF_RT_KERNEL_VER}-${ARMHF_RT_VER}.patch.gz" >&2
	    my_exit
	fi
    fi
}

copy_dts()
{
    echo "copy devicetree config to kernel sources"

    cp $ARMHF_HOME/bananapi/configs/sun7i-a20-bananapi.dts arch/arm/boot/dts/sun7i-a20-bananapi.dts
    cp $ARMHF_HOME/bananapi-pro/configs/sun7i-a20-bananapro.dts arch/arm/boot/dts/sun7i-a20-bananapro.dts
    cp $ARMHF_HOME/bananapi-m3/configs/sun8i-a83t-bananapi-m3.dts arch/arm/boot/dts/sun8i-a83t-bananapi-m3.dts
    cp $ARMHF_HOME/cubietruck/configs/sun7i-a20-cubietruck.dts arch/arm/boot/dts/sun7i-a20-cubietruck.dts
    cp $ARMHF_HOME/cubietruck-plus/configs/sun8i-a83t-cubietruck-plus.dts arch/arm/boot/dts/sun8i-a83t-cubietruck-plus.dts
    cp $ARMHF_HOME/olimex/configs/sun7i-a20-olimex-som-evb.dts arch/arm/boot/dts/sun7i-a20-olimex-som-evb.dts
    cp $ARMHF_HOME/nanopi/configs/sun8i-h3-nanopi-neo.dts arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts
    cp $ARMHF_HOME/orangepi-zero/configs/sun8i-h2-plus-orangepi-zero.dts arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
}

build_dtb()
{
    echo "build devicetree blob"

    if [ "$MY_HOST_ARCH" = 'x86_64' ]; then
	make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- sun7i-a20-bananapi.dtb
	make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- sun7i-a20-olimex-som-evb.dtb
	make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- sun7i-a20-bananapro.dtb
	make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- sun8i-a83t-bananapi-m3.dtb
	make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- sun7i-a20-cubietruck.dtb
	make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- sun8i-a83t-cubietruck-plus.dtb
	make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- sun8i-h3-nanopi-neo.dtb
	make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- sun8i-h2-plus-orangepi-zero.dtb
    else
	make sun7i-a20-bananapi.dtb
	make sun7i-a20-olimex-som-evb.dtb
	make sun7i-a20-bananapro.dtb
	make sun7i-a20-cubietruck.dtb
	make sun8i-a83t-cubietruck-plus.dtb
	make sun8i-a83t-bananapi-m3.dtb
	make sun8i-h3-nanopi-neo.dtb
	make sun8i-h2-plus-orangepi-zero.dtb
    fi
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

if [ ! "$BUILD_NONRT" = 'true' ] &&  [ ! "$BUILD_RT" = 'true' ]; then
    echo "+--------------------------------------+"
    echo "| no kdo to build a kernel -> leave    |"
    echo "+--------------------------------------+"
    my_exit
fi

${ARMHF_HOME}/scripts/check_for_valid_env.sh
if [ $? -ne 0 ]; then
    echo "+--------------------------------------+"
    echo "| env variable and env script are NOT  |"
    echo "| in sync                              |"
    echo "+--------------------------------------+"
    my_exit
fi

echo " "
echo "+----------------------------------------+"
echo "|       build all kernel from source     |"
echo "+----------------------------------------+"
echo " "

if [ -d ${ARMHF_BIN_HOME}/kernel ]; then
    cd ${ARMHF_BIN_HOME}/kernel
else
    echo "ERROR -> ${ARMHF_BIN_HOME}/kernel not exists ... do a make init_sdk"
fi

check_tarballs

if [ "$BUILD_NONRT" = 'true' ]; then
    echo "build non-rt kernel"
    cd ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_KERNEL_VER}
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not cd to kernel_${ARMHF_KERNEL_VER}" >&2
        my_exit
    fi

    cp $ARMHF_HOME/bananapi/configs/kernel_config .config

    copy_dts
    build_dtb

    if [ "$MY_HOST_ARCH" = 'x86_64' ]; then
	echo "make -j $NUM_CORES ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- LOADADDR=0x40008000 uImage modules"
	make -j $NUM_CORES ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- LOADADDR=0x40008000 uImage modules
    else
	echo "make -j $NUM_CORES LOADADDR=0x40008000 uImage modules"
	make -j $NUM_CORES LOADADDR=0x40008000 uImage modules
    fi
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not build kernel" >&2
        my_exit
    fi

    if [ "$MY_HOST_ARCH" = 'x86_64' ]; then
	make ARCH=arm INSTALL_MOD_PATH=../modules_${ARMHF_KERNEL_VER} modules_install
    else
	make INSTALL_MOD_PATH=../modules_${ARMHF_KERNEL_VER} modules_install
    fi
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not install kernel modules" >&2
        my_exit
    fi
fi

if [ "$BUILD_RT" = 'true' ]; then
    echo "configure rt kernel"
    cd ${ARMHF_BIN_HOME}/kernel/linux-${ARMHF_RT_KERNEL_VER}_rt
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not cd to kernel_${ARMHF_KERNEL_VER}_rt" >&2
        my_exit
    fi

    zcat ../patch-${ARMHF_RT_KERNEL_VER}-${ARMHF_RT_VER}.patch.gz | patch -p1
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not patch kernel with rt-preempt" >&2
        my_exit
    fi
    sync
    cp $ARMHF_HOME/bananapi/configs/kernel_config_rt .config

    copy_dts
    build_dtb

    if [ "$MY_HOST_ARCH" = 'x86_64' ]; then
	echo "make -j $NUM_CORES ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- LOADADDR=0x40008000 uImage modules"
	make -j $NUM_CORES ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- LOADADDR=0x40008000 uImage modules
    else
	echo "make -j $NUM_CORES LOADADDR=0x40008000 uImage modules"
	make -j $NUM_CORES LOADADDR=0x40008000 uImage modules
    fi
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not build kernel" >&2
        my_exit
    fi

    if [ "$MY_HOST_ARCH" = 'x86_64' ]; then
	make ARCH=arm INSTALL_MOD_PATH=../modules_${ARMHF_RT_KERNEL_VER}_rt modules_install
    else
	make INSTALL_MOD_PATH=../modules_${ARMHF_RT_KERNEL_VER}_rt modules_install
    fi
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not install kernel modules" >&2
        my_exit
    fi
fi

cleanup
echo " "
echo "+----------------------------------------+"
echo "|            Cheers $USER "
echo "+----------------------------------------+"
echo " "
