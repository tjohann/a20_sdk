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
# Date/Beginn :    27.09.2016/17.04.2016
#
# Version     :    V2.00
#
# Milestones  :    V2.00 (sep 2016) -> update version info fo A20_SDK_V2.0.0
#                  V1.06 (sep 2016) -> add can_lin_env
#                  V1.05 (aug 2016) -> sudo handling at beginning
#                  V1.04 (jul 2016) -> add features of make_sdcard.sh
#                  V1.03 (jul 2016) -> add mrproper to remove $ARMHF_*_HOME
#                                      some minor rework of the code
#                                      change exit code to 3
#                  V1.02 (jul 2016) -> remove links to kernel/...
#                  V1.01 (jul 2016) -> some minor improvements
#                  V1.00 (jul 2016) -> release V1.00
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
VER='2.00'

# if env is sourced
MISSING_ENV='false'

# what to clean
CLEAN_KERNEL='false'
CLEAN_EXTERNAL='false'
CLEAN_IMAGES='false'
CLEAN_TOOLCHAIN='false'
CLEAN_USER='false'
MRPROPER='false'

# program name
PROGRAM_NAME=${0##*/}

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ${PROGRAM_NAME} "
    echo "|        [-a] -> cleanup all dir                         |"
    echo "|        [-k] -> cleanup kernel dir                      |"
    echo "|        [-e] -> cleanup external dir                    |"
    echo "|        [-i] -> cleanup image dir                       |"
    echo "|        [-t] -> cleanup toolchain parts                 |"
    echo "|        [-u] -> cleanup user home dir parts             |"
    echo "|        [-m] -> remove /opt/a20* and $HOME/src/a20*     |"
    echo "|                parts                                   |"
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
while getopts 'hvaketium' opts 2>$_log
do
    case $opts in
	k) CLEAN_KERNEL='true' ;;
	e) CLEAN_EXTERNAL='true' ;;
	i) CLEAN_IMAGES='true' ;;
	t) CLEAN_TOOLCHAIN='true' ;;
	u) CLEAN_USER='true' ;;
	m) MRPROPER='true' ;;
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

clean_images()
{
    if [ -d $ARMHF_BIN_HOME/images ]; then
        cd $ARMHF_BIN_HOME/images
	rm -rf *.tgz
	echo "cleanup image dir"
    else
        echo "INFO: no directory ${ARMHF_BIN_HOME}/images"
    fi
}

clean_external()
{
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
	rm -rf can_lin_env
    else
        echo "INFO: no directory ${ARMHF_BIN_HOME}/external"
    fi
}

clean_kernel()
{
    if [ -d $ARMHF_BIN_HOME/kernel ]; then
        cd $ARMHF_BIN_HOME/kernel
	echo "cleanup kernel dir"
	rm -rf linux-*
	rm -rf modules_*
	rm -rf patch-*
    else
        echo "INFO: no directory ${ARMHF_BIN_HOME}/kernel"
    fi
}

clean_toolchain()
{
    if [ -d $ARMHF_BIN_HOME ]; then
	cd $ARMHF_BIN_HOME
    	echo "cleanup toolchain parts"
	rm -rf host*
	rm -rf toolchain*
    else
        echo "INFO: no directory $ARMHF_BIN_HOME"
    fi
}

clean_user()
{
    if [ -d $ARMHF_SRC_HOME ]; then
	cd $ARMHF_SRC_HOME
    	echo "cleanup user specific parts"
	rm -rf bin
	rm -rf examples
	rm -rf include
	rm -rf lib*
	rm -rf Documentation
	rm -rf kernel
	rm -rf images
	rm -rf external
    else
        echo "INFO: no directory $ARMHF_SRC_HOME"
    fi
}

do_mrproper()
{
    if [ -d $ARMHF_SRC_HOME ]; then
	cd $ARMHF_HOME
	rm -rf $ARMHF_SRC_HOME
    else
        echo "INFO: no directory $ARMHF_SRC_HOME"
    fi
    if [ -d $ARMHF_BIN_HOME ]; then
	cd $ARMHF_HOME
	sudo rm -rf $ARMHF_BIN_HOME
    else
        echo "INFO: no directory $ARMHF_BIN_HOME"
    fi
}

# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

# sudo handling up-front
echo " "
echo "+------------------------------------------+"
echo "| cleanup the sdk                          |"
echo "| --> need sudo for some parts             |"
echo "+------------------------------------------+"
echo " "

sudo -v
# keep-alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

if [ "$CLEAN_IMAGES" = 'true' ]; then
    clean_images
else
    echo "do not clean ${ARMHF_BIN_HOME}/images"
fi

if [ "$CLEAN_EXTERNAL" = 'true' ]; then
    clean_external
else
    echo "do not clean ${ARMHF_BIN_HOME}/external"
fi

if [ "$CLEAN_KERNEL" = 'true' ]; then
    clean_kernel
else
    echo "do not clean ${ARMHF_BIN_HOME}/kernel"
fi

if [ "$CLEAN_TOOLCHAIN" = 'true' ]; then
    clean_toolchain
else
    echo "do not clean toolchain parts"
fi

if [ "$CLEAN_USER" = 'true' ]; then
	clean_user
else
    echo "do not clean $ARMHF_SRC_HOME"
fi

if [ "$MRPROPER" = 'true' ]; then
	do_mrproper
else
    echo "do not mrproper"
fi

cleanup
echo " "
echo "+----------------------------------------+"
echo "|            Cheers $USER"
echo "+----------------------------------------+"
echo " "
