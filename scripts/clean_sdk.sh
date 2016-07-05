#!/usr/bin/env bash
################################################################################
#
# Title       :    clean_sdk.sh
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
# Date/Beginn :    05.07.2016/17.04.2016
#
# Version     :    V1.00
#
# Milestones  :    V1.00 (jul 2016) -> release V1.00
#                  V0.05 (jul 2016) -> some minor improvements
#                  V0.04 (may 2016) -> add libbaalue and baalued
#                  V0.03 (may 2016) -> add missing externals
#                                      add cleanup $ARMHF_SRC_DIR
#                  V0.02 (apr 2016) -> finalize
#                                      add content to cleanup toolchain stuff
#                  V0.01 (apr 2016) -> first skeleton version
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to cleanup parts of the sdk
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
VER='1.00'

# if env is sourced
MISSING_ENV='false'

# what to clean
CLEAN_KERNEL='false'
CLEAN_EXTERNAL='false'
CLEAN_IMAGES='false'
CLEAN_TOOLCHAIN='false'
CLEAN_USER='false'

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ./clean_sdk.sh                                  |"
    echo "|        [-a] -> cleanup all dir                         |"
    echo "|        [-k] -> cleanup kernel dir                      |"
    echo "|        [-e] -> cleanup external dir                    |"
    echo "|        [-i] -> cleanup image dir                       |"
    echo "|        [-t] -> cleanup toolchain parts                 |"
    echo "|        [-u] -> cleanup user home dir parts             |"
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
    clear
    echo "+-----------------------------------+"
    echo "|          Cheers $USER            |"
    echo "+-----------------------------------+"
    cleanup
    exit
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
_temp="/tmp/clean_sdk.$$"
_log="/tmp/clean_sdk.log"


# check the args
while getopts 'hvaketiu' opts 2>$_log
do
    case $opts in
	k) CLEAN_KERNEL='true' ;;
	e) CLEAN_EXTERNAL='true' ;;
	i) CLEAN_IMAGES='true' ;;
	t) CLEAN_TOOLCHAIN='true' ;;
	u) CLEAN_USER='true' ;;
	a) CLEAN_KERNEL='true'
           CLEAN_EXTERNAL='true'
           CLEAN_IMAGES='true'
	   CLEAN_TOOLCHAIN='true'
	   CLEAN_USER='true'
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
    clear
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
echo "|             cleanup the sdk            |"
echo "+----------------------------------------+"
echo " "

if [ "$CLEAN_IMAGES" = 'true' ]; then
    if [ -d $ARMHF_BIN_HOME/images ]; then
        cd $ARMHF_BIN_HOME/images
	rm -rf *.tgz
	echo "cleanup image dir"
    else
        echo "INFO: no dir images below ${ARMHF_BIN_HOME}/images"
    fi
else
    echo "do not clean ${ARMHF_BIN_HOME}/images"
fi

if [ "$CLEAN_EXTERNAL" = 'true' ]; then
    if [ -d $ARMHF_BIN_HOME/external ]; then
        cd $ARMHF_BIN_HOME/external
	echo "cleanup external dir"
	rm -rf can-utils
	rm -rf documents
	rm -rf jailhouse
	rm -rf rt-tests
	rm -rf sdk_builder
	rm -rf u-boot
	rm -rf mydriver
	rm -rf lcd160x_driver
	rm -rf libbaalue
	rm -rf baalued
	rm -rf time_triggert_env
    else
        echo "INFO: no dir external below ${ARMHF_BIN_HOME}/external"
    fi
else
    echo "do not clean ${ARMHF_BIN_HOME}/external"
fi

if [ "$CLEAN_KERNEL" = 'true' ]; then
    if [ -d $ARMHF_BIN_HOME/kernel ]; then
        cd $ARMHF_BIN_HOME/kernel
	echo "cleanup kernel dir"
	rm -rf linux-*
	rm -rf modules_*
	rm -rf patch-*
    else
        echo "INFO: no dir kernel below ${ARMHF_BIN_HOME}/kernel"
    fi
else
    echo "do not clean ${ARMHF_BIN_HOME}/kernel"
fi

if [ "$CLEAN_TOOLCHAIN" = 'true' ]; then
    if [ -d $ARMHF_BIN_HOME ]; then
	cd $ARMHF_BIN_HOME
    	echo "cleanup toolchain parts"
	rm -rf host*
	rm -rf toolchain*
    else
        echo "INFO: no $ARMHF_BIN_HOME"
    fi
else
    echo "do not clean toolchain parts"
fi

if [ "$CLEAN_USER" = 'true' ]; then
    if [ -d $ARMHF_SRC_HOME ]; then
	cd $ARMHF_SRC_HOME
    	echo "cleanup user specific parts"
	rm -rf bin
	rm -rf examples
	rm -rf include
	rm -rf lib*
    else
        echo "INFO: no $ARMHF_SRC_HOME"
    fi
else
    echo "do not clean toolchain parts"
fi

cleanup
echo " "
echo "+----------------------------------------+"
echo "|          Cheers $USER                |"
echo "+----------------------------------------+"
echo " "
