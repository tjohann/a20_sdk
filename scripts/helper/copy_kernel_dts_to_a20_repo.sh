#!/usr/bin/env bash
################################################################################
#
# Title       :    copy_kernel_dts_to_a20_repo.sh
#
# License:
#
# GPL
# (c) 2022, thorsten.johannvorderbrueggen@t-online.de
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
# Date/Beginn :    16.04.2022/16.04.2022
#
# Version     :    V0.01
#
# Milestones  :    V0.01 (apr 2022) -> first functional version
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to copy the actual dts configs from a kernel tree to
#   $ARMHF_HOME/*/configs/ ...
#
# Some features
#   - ...
#
# Notes
#   - ...
################################################################################
#

# VERSION-NUMBER
VER='0.01'

# if env is sourced
MISSING_ENV='false'

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
# ***                         Main Loop                                      ***
# ******************************************************************************

echo " "
echo "+------------------------------------------------------------+"
echo "|  copy latest dts configs to the local a20_sdk installation |"
echo "+------------------------------------------------------------+"
echo " "


# Bananapi
if [ -d $ARMHF_HOME/bananapi/configs/ ]; then
    if [ -f arch/arm/boot/dts/sun7i-a20-bananapi.dts ]; then
	cp arch/arm/boot/dts/sun7i-a20-bananapi.dts $ARMHF_HOME/bananapi/configs/sun7i-a20-bananapi.dts
    else
	echo "ERROR -> arch/arm/boot/dts/sun7i-a20-bananapi.dts does not exist" >&2
	my_exit
    fi
else
    echo "ERROR -> $ARMHF_HOME/bananapi/configs/ doesn't exist" >&2
    my_exit
fi

# Bananapi-Pro
if [ -d $ARMHF_HOME/bananapi-pro/configs/ ]; then
    if [ -f arch/arm/boot/dts/sun7i-a20-bananapro.dts ]; then
	cp arch/arm/boot/dts/sun7i-a20-bananapro.dts $ARMHF_HOME/bananapi-pro/configs/sun7i-a20-bananapro.dts
    else
	echo "ERROR -> arch/arm/boot/dts/sun7i-a20-bananapro.dts does not exist" >&2
	my_exit
    fi
else
    echo "ERROR -> $ARMHF_HOME/bananapi-pro/configs/ doesn't exist" >&2
    my_exit
fi

# Bananapi-M3
if [ -d $ARMHF_HOME/bananapi-m3/configs/ ]; then
    if [ -f arch/arm/boot/dts/sun8i-a83t-bananapi-m3.dts ]; then
	cp arch/arm/boot/dts/sun8i-a83t-bananapi-m3.dts $ARMHF_HOME/bananapi-m3/configs/sun8i-a83t-bananapi-m3.dts
    else
	echo "ERROR -> arch/arm/boot/dts/sun8i-a83t-bananapi-m3.dts does not exist" >&2
	my_exit
    fi
else
    echo "ERROR -> $ARMHF_HOME/bananapi-m3/configs/ doesn't exist" >&2
    my_exit
fi

# Cubitruck
if [ -d  $ARMHF_HOME/cubietruck/configs/ ]; then
    if [ -f arch/arm/boot/dts/sun7i-a20-cubietruck.dts ]; then
	cp arch/arm/boot/dts/sun7i-a20-cubietruck.dts $ARMHF_HOME/cubietruck/configs/sun7i-a20-cubietruck.dts
    else
	echo "ERROR -> arch/arm/boot/dts/sun7i-a20-cubietruck.dts does not exist" >&2
	my_exit
    fi
else
    echo "ERROR -> $ARMHF_HOME/cubietruck/configs/ doesn't exist" >&2
    my_exit
fi

# Olimex A20 SOM
if [ -d  $ARMHF_HOME/olimex/configs/ ]; then
    if [ -f arch/arm/boot/dts/sun7i-a20-olimex-som-evb.dts ]; then
	cp arch/arm/boot/dts/sun7i-a20-olimex-som-evb.dts $ARMHF_HOME/olimex/configs/sun7i-a20-olimex-som-evb.dts
    else
	echo "ERROR -> arch/arm/boot/dts/sun7i-a20-olimex-som-evb.dts does not exist" >&2
	my_exit
    fi
else
    echo "ERROR -> $ARMHF_HOME/olimex/configs/ doesn't exist" >&2
    my_exit
fi

# Nanopi
if [ -d  $ARMHF_HOME/nanopi/configs/ ]; then
    if [ -f arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts ]; then
	cp arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts $ARMHF_HOME/nanopi/configs/sun8i-h3-nanopi-neo.dts
    else
	echo "ERROR -> arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts does not exist" >&2
	my_exit
    fi
else
    echo "ERROR -> $ARMHF_HOME/nanopi/configs/ doesn't exist" >&2
    my_exit
fi

# Cubitruck-Plus
if [ -d  $ARMHF_HOME/cubietruck-plus/configs ]; then
    if [ -f arch/arm/boot/dts/sun8i-a83t-cubietruck-plus.dts ]; then
	cp arch/arm/boot/dts/sun8i-a83t-cubietruck-plus.dts $ARMHF_HOME/cubietruck-plus/configs/sun8i-a83t-cubietruck-plus.dts
    else
	echo "ERROR -> arch/arm/boot/dts/sun8i-a83t-cubietruck-plus.dts does not exist" >&2
	my_exit
    fi
else
    echo "ERROR -> $ARMHF_HOME/cubietruck-plus/configs doesn't exist" >&2
    my_exit
fi

# Orangepi-Zero
if [ -d  $ARMHF_HOME/orangepi-zero/configs/ ]; then
    if [ -f arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts ]; then
	cp arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts $ARMHF_HOME/orangepi-zero/configs/sun8i-h2-plus-orangepi-zero.dts
    else
	echo "ERROR -> arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts does not exist" >&2
	my_exit
    fi
else
    echo "ERROR -> $ARMHF_HOME/orangepi-zero/configs/ doesn't exist" >&2
    my_exit
fi


cleanup
echo " "
echo "+----------------------------------------+"
echo "|            Cheers $USER"
echo "+----------------------------------------+"
echo " "

