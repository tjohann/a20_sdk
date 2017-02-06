#!/usr/bin/env bash
################################################################################
#
# Title       :    build_uboot.sh
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
# Date/Beginn :    06.02.2017/02.12.2016
#
# Version     :    V0.02
#
# Milestones  :    V0.01 (dec 2016) -> initial version
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to build u-boot (see howto_uboot.txt)
#
# Notes
#   ...
#
################################################################################
#

# VERSION-NUMBER
VER='0.02'

# if env is sourced
MISSING_ENV='false'

# which brand?
BRAND='none'

# which uboot config
UBOOT_CONFIG='none'

# program name
PROGRAM_NAME=${0##*/}

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ${PROGRAM_NAME} "
    echo "|        [-b] -> bananapi/bananapi-pro/olimex/baalue/    |"
    echo "|                cubietruck/nanopi                       |"
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
    echo " "
    echo "+----------------------------------------+"
    echo "|          Cheers $USER            "
    echo "+----------------------------------------+"
    echo " "
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
while getopts 'hvb:' opts 2>$_log
do
    case $opts in
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

USED_CMD="arm-none-linux-gnueabihf-gcc"
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

check_uboot_repo()
{
    local repo_name="http://git.denx.de/u-boot.git"

    if [[ ! -d "${REPO_PATH}/u-boot" ]]; then
	echo "${repo_name}/u-boot not available -> clone it" >&2

	cd ${REPO_PATH}
	 if [ $? -ne 0 ] ; then
	     echo "ERROR -> could not cd to $repo_name" >&2
	     my_exit
	 fi

	 echo "start to clone repo $repo_name"
	 git clone $repo_name
	 if [ $? -ne 0 ] ; then
	     echo "ERROR -> could not clone ${repo_name}" >&2
	     my_exit
	 fi
    else
	cd ${REPO_PATH}/u-boot
	echo "${REPO_PATH}/u-boot available -> pull updates" >&2
	git pull
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not pull updates ${repo_name}" >&2
	    my_exit
	fi
    fi
}

config_uboot()
{
    echo "configure uboot with $UBOOT_CONFIG to build for $BRAND"

    cd ${REPO_PATH}/u-boot

    make clean
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not clean ${REPO_PATH}/u-boot" >&2
        my_exit
    fi

    make $UBOOT_CONFIG
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not configure uboot for $UBOOT_CONFIG" >&2
        my_exit
    fi
}

build_uboot()
{
    echo "build uboot with $UBOOT_CONFIG to build for $BRAND"
    cd ${REPO_PATH}/u-boot

    make CROSS_COMPILE=arm-none-linux-gnueabihf-
    if [ $? -ne 0 ] ; then
        echo "ERROR -> could not build uboot" >&2
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
    'bananapi')
	UBOOT_CONFIG="Bananapi_defconfig"
        ;;
    'bananapi-pro')
	UBOOT_CONFIG="Bananapro_defconfig"
        ;;
    'olimex')
	UBOOT_CONFIG="A20-Olimex-SOM-EVB_defconfig"
        ;;
    'cubietruck')
	UBOOT_CONFIG="Cubietruck_defconfig"
        ;;
    'nanopi')
	UBOOT_CONFIG="nanopi_neo_defconfig"
        ;;
    *)
        echo "ERROR -> ${BRAND} is not supported ... pls check" >&2
        my_exit
esac

REPO_PATH="${ARMHF_BIN_HOME}/external"
check_uboot_repo

config_uboot
build_uboot

cleanup
echo " "
echo "+----------------------------------------+"
echo "|            Cheers $USER "
echo "+----------------------------------------+"
echo " "
