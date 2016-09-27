#!/usr/bin/env bash
################################################################################
#
# Title       :    get_latest_linux_kernel.sh
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
# Date/Beginn :    27.09.2016/15.08.2015
#
# Version     :    V2.00
#
# Milestones  :    V2.00 (sep 2016) -> update version info fo A20_SDK_V2.0.0
#                  V1.04 (jul 2016) -> add features of make_sdcard.sh
#                  V1.03 (jul 2016) -> redirect errors to >&2
#                  V1.02 (jul 2016) -> change exit code to 3
#                  V1.01 (jul 2016) -> some minor improvements
#                  V1.00 (jul 2016) -> add check for sync of armhf_env and $ARM*
#                                      fix RT download dependency
#                  V0.09 (jul 2016) -> update RT to 4.6
#                  V0.08 (jul 2016) -> some minor improvements
#                  V0.07 (apr 2016) -> create $ARMHF_BIN_HOME/* if it not exist
#                                      fix wrong rt-preempt-patch download link
#                  V0.06 (mar 2016) -> untar rt source to linux-*_rt
#                  V0.05 (mar 2016) -> add missing check for dir
#                  V0.04 (jan 2016) -> implement new architecture
#                  V0.03 (jan 2016) -> update RT to 4.4
#                  V0.02 (jan 2016) -> adapt it for usage within a20_sdk
#                  V0.01 (aug 2015) -> first functional version
#
# Requires    :    ...
#
#
################################################################################
# Description
#
#   A simple tool to get the latest kernel tarball and copy it to
#   $ARMHF_BIN_HOME/kernel ...
#
# Some features
#   - ...
#
# Notes
#   - ...
#
################################################################################
#

# VERSION-NUMBER
VER='2.00'

# if env is sourced
MISSING_ENV='false'

# latest kernel/rt-preempt version
KERNEL_VER='none'
RT_KERNEL_VER='none'
DOWNLOAD_STRING='none'

# what to download
DOWNLOAD_RT='false'
DOWNLOAD_NONRT='false'

# program name
PROGRAM_NAME=${0##*/}

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ${PROGRAM_NAME} "
    echo "|        [-r] -> download only rt kernel parts           |"
    echo "|        [-n] -> download only non-rt kernel parts       |"
    echo "|        [-a] -> download all parts                      |"
    echo "|        [-v] -> print version info                      |"
    echo "|        [-h] -> this help                               |"
    echo "|                                                        |"
    echo "| This small tool download based on the values of        |"
    echo "| ARMHF_KERNEL_VER, ARMHF_RT_KERNEL_VER and              |"
    echo "| ARMHF_RT_VER the needed source files to build a        |"
    echo "| custom kernel.                                         |"
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
	r) DOWNLOAD_RT='true' ;;
	n) DOWNLOAD_NONRT='true' ;;
	a) DOWNLOAD_RT='true'
	   DOWNLOAD_NONRT='true'
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

if [[ ! ${ARMHF_KERNEL_VER} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${ARMHF_RT_KERNEL_VER} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${ARMHF_RT_VER} ]]; then
    MISSING_ENV='true'
fi

# show a usage screen and exit
if [ "$MISSING_ENV" = 'true' ]; then
    cleanup
    echo " "
    echo "+--------------------------------------+"
    echo "|  ERROR: missing env                  |"
    echo "|         have you sourced env-file?   |"
    echo "+--------------------------------------+"
    echo " "
    exit
fi


# ******************************************************************************
# ***                      The functions for main_menu                       ***
# ******************************************************************************

# --- get the kernel sources
get_kernel_source()
{
    DOWNLOAD_STRING="https://www.kernel.org/pub/linux/kernel/v4.x/linux-${KERNEL_VER}.tar.xz"
    echo "INFO: set kernel download string to $DOWNLOAD_STRING"

    if [ -f linux-${KERNEL_VER}.tar.xz ]; then
	echo " "
	echo "+--------------------------------------+"
	echo "|  INFO: linux-${KERNEL_VER}.tar.xz    |"
	echo "|        already exist, wont download  |"
	echo "|        again                         |"
	echo "+--------------------------------------+"
	echo " "

	tar xvf linux-${KERNEL_VER}.tar.xz
    else
	wget $DOWNLOAD_STRING
	if [ $? -ne 0 ]; then
	    echo " ERROR -> could not download ${DOWNLOAD_STRING}" >&2
	else
	   tar xvf linux-${KERNEL_VER}.tar.xz
	fi
    fi

    # reset value
    DOWNLOAD_STRING='none'
}

# --- get the rt-preempt patch sources
get_rt_patch_source()
{
    MAYOR_MINOR=`echo $ARMHF_RT_KERNEL_VER | cut -d . -f 1,2`
    DOWNLOAD_STRING="https://www.kernel.org/pub/linux/kernel/projects/rt/${MAYOR_MINOR}/patch-${KERNEL_VER}-${ARMHF_RT_VER}.patch.gz"
    echo "INFO: set rt-preempt patch download string to $DOWNLOAD_STRING"

    if [ -f patch-${KERNEL_VER}-${ARMHF_RT_VER}.patch.gz ]; then
	echo " "
	echo "+--------------------------------------+"
	echo "|  INFO: patch-${KERNEL_VER}-${ARMF_RT_VER}.patch.gz"
	echo "|        already exist, wont download  |"
	echo "|        again                         |"
	echo "+--------------------------------------+"
	echo " "
    else
	wget $DOWNLOAD_STRING
	if [ $? -ne 0 ]; then
	    echo "ERROR -> could not download patch-${KERNEL_VER}-${ARMHF_RT_VER}.patch.gz" >&2
	fi
    fi

    # reset value
    DOWNLOAD_STRING='none'
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

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
echo "|       get/install kernel source        |"
echo "+----------------------------------------+"
echo " "

if [ -d ${ARMHF_BIN_HOME}/kernel ]; then
    cd ${ARMHF_BIN_HOME}/kernel
else
    mkdir -p ${ARMHF_BIN_HOME}/kernel
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not mkdir -p ${ARMHF_BIN_HOME}/kernel" >&2
	my_exit
    fi
    cd ${ARMHF_BIN_HOME}/kernel
fi

if [ "$DOWNLOAD_RT" = 'true' ]; then
    # FULL_RT_PREEMPT handling
    KERNEL_VER=$ARMHF_RT_KERNEL_VER
    echo "INFO: set kernel version to linux-$KERNEL_VER and linux-$RT_KERNEL_VER "
    get_kernel_source

    # mv linux-$ARMHF_RT_KERNEL_VER to linux-$ARMHF_RT_KERNEL_VER_rt
    mv linux-${ARMHF_RT_KERNEL_VER} linux-${ARMHF_RT_KERNEL_VER}_rt
     if [ $? -ne 0 ] ; then
	echo "ERROR -> could mv linux-${ARMHF_RT_KERNEL_VER} to linux-${ARMHF_RT_KERNEL_VER}_rt" >&2
	my_exit
    fi

    # rt-preempt patch
    get_rt_patch_source
fi

if [ "$DOWNLOAD_NONRT" = 'true' ]; then
    KERNEL_VER=$ARMHF_KERNEL_VER
    get_kernel_source
fi

cleanup
echo " "
echo "+----------------------------------------+"
echo "|            Cheers $USER"
echo "+----------------------------------------+"
echo " "

