#!/usr/bin/env bash
################################################################################
#
# Title       :    get_toolchain.sh
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
#                  V1.00 (jul 2016) -> some minor improvements
#                  V0.05 (jul 2016) -> some minor improvements
#                  V0.04 (apr 2016) -> check for architecture
#                                      some more error checks/cleanups
#                  V0.03 (jan 2016) -> adapt for new architecture
#                  V0.02 (jan 2016) -> adapt for usage in a20_sdk
#                  V0.01 (aug 2015) -> first functional version
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to get the toolchain and untar it to $ARMHF_BIN_HOME  ...
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
VER='2.00'

# if env is sourced
MISSING_ENV='false'

#
# latest version
#
# VER:
# -> host_x86_64.tgz
# -> toolchain_x86_64.tgz
#
# DOWNLOAD_STRING:
# -> http://sourceforge.net/projects/a20devices/files/host_x86_64.tgz
# -> http://sourceforge.net/projects/a20devices/files/toolchain_x86_64.tgz
#
TOOLCHAIN_VER='none'
TOOLCHAIN_HOST_VER='none'
TOOLCHAIN_DOWNLOAD_STRING='none'
TOOLCHAIN_HOST_DOWNLOAD_STRING='none'

# program name
PROGRAM_NAME=${0##*/}

# my usage method
my_usage()
{
    echo " "
    echo "+------------------------------------------+"
    echo "| Usage: ${PROGRAM_NAME} "
    echo "|        [-v] -> print version info        |"
    echo "|        [-h] -> this help                 |"
    echo "|                                          |"
    echo "+------------------------------------------+"
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
    echo "+------------------------------------------+"
    echo "|          Cheers $USER                   |"
    echo "+------------------------------------------+"
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


# --- create download string
create_download_string()
{
   TOOLCHAIN_DOWNLOAD_STRING="http://sourceforge.net/projects/a20devices/files/toolchain_x86_64.tgz"
   TOOLCHAIN_HOST_DOWNLOAD_STRING="http://sourceforge.net/projects/a20devices/files/host_x86_64.tgz"

   echo "INFO: set toolchain download string to $TOOLCHAIN_DOWNLOAD_STRING and $TOOLCHAIN_HOST_DOWNLOAD_STRING"
}


# --- download toolchain tarball
get_toolchain_tarball()
{
    if [ "$TOOLCHAIN_DOWNLOAD_STRING" = 'none' ]; then
	echo " "
	echo "+--------------------------------------+"
	echo "|  ERROR: TOOLCHAIN_DOWNLOAD_STRING is |"
	echo "|         none!                        |"
	echo "+--------------------------------------+"
	echo " "
	my_exit
    fi

    if [ "$TOOLCHAIN_HOST_DOWNLOAD_STRING" = 'none' ]; then
	echo " "
	echo "+--------------------------------------+"
	echo "|  ERROR:                              |"
	echo "|        TOOLCHAIN_HOST_DOWNLOAD_STRING|"
	echo "|        is none!                      |"
	echo "+--------------------------------------+"
	echo " "
	my_exit
    fi

    wget $TOOLCHAIN_DOWNLOAD_STRING
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not download ${TOOLCHAIN_DOWNLOAD_STRING}" >&2
	my_exit
    fi
    wget $TOOLCHAIN_HOST_DOWNLOAD_STRING
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not download ${TOOLCHAIN_HOST_DOWNLOAD_STRING}" >&2
	my_exit
    fi
}

# --- untar toolchain source
untar_toolchain()
{
    if [ -f toolchain_x86_64.tgz ]; then
	tar xzvf toolchain_x86_64.tgz
    else
	echo "ERROR -> toolchain_x86_64.tgz does not exist" >&2
	my_exit
    fi

    if [ -f host_x86_64.tgz ]; then
	tar xzvf host_x86_64.tgz
    else
	echo "ERROR -> host_x86_64.tgz does not exist" >&2
	my_exit
    fi
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

echo " "
echo "+----------------------------------------+"
echo "|  get/install latest toolchain tarball  |"
echo "+----------------------------------------+"
echo " "

if [ $(uname -m) == 'x86_64' ]; then

    if [ -d $ARMHF_BIN_HOME ]; then
	cd $ARMHF_BIN_HOME
    else
	echo "ERROR -> $ARMHF_BIN_HOME doesn't exist -> do a make init_sdk" >&2
	my_exit
    fi

    create_download_string
    get_toolchain_tarball
    untar_toolchain
else
    echo "INFO: no toolchain for your architecture $(uname -m)"
fi

cleanup
echo " "
echo "+----------------------------------------+"
echo "|            Cheers $USER"
echo "+----------------------------------------+"
echo " "

