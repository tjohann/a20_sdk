#!/usr/bin/env bash
################################################################################
#
# Title       :    build_base_repos.sh
#
# License:
#
# GPL
# (c) 2016-2021, thorsten.johannvorderbrueggen@t-online.de
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
# Date/Beginn :    04.03.2021/26.09.2016
#
# Version     :    V2.06
#
# Milestones  :    V2.06 (mar 2021) -> change configure defaults for libbaalue
#                  V2.05 (jan 2018) -> add baalue
#                  V2.04 (nov 2017) -> reduce number of base repos
#                  V2.03 (feb 2017) -> fix uninstall function
#                                      change build order -> kernel driver needed
#                                      for libbaalue (lcd160x part)
#                  V2.02 (jan 2017) -> fix wrong debug argument for *baalue*
#                  V2.01 (dec 2016) -> fix wrong location
#                  V2.00 (sep 2016) -> update version info fo A20_SDK_V2.0.0
#                                      add make uninstall target
#                                      fix some smaller bugs/problems
#                  V0.01 (sep 2016) -> first working version
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to build my base external repository (on the device)
#
#   Workdir /opt/a20_sdk/external
#
# Some features
#   - ...
#
################################################################################
#

# VERSION-NUMBER
VER='2.06'

# if env is sourced
MISSING_ENV='false'

# program name
PROGRAM_NAME=${0##*/}

# the current repo
BUILD_DIR='none'

# additional configure arguments
CONFIGURE_ADDS=''

# do a un/deinstall?
UNINSTALL='none'

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ${PROGRAM_NAME} "
    echo "|        [-u] -> uninstall base_repo                     |"
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
    # if something is still mounted
    umount_partition

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
while getopts 'hvu' opts 2>$_log
do
    case $opts in
        h) my_usage ;;
	u) UNINSTALL='true' ;;
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

build_autotools()
{
    ./configure ${CONFIGURE_ADDS} --prefix=/usr/local
    make
    sudo make install
    sudo ldconfig
}

build_autogen()
{
    if [ -d ${BUILD_DIR} ]; then
	cd ${BUILD_DIR}
	./autogen.sh
	build_autotools
    else
	echo "ERROR -> ${BUILD_DIR} no available!"
    fi
}

build_bootstrap()
{
    if [ -d ${BUILD_DIR} ]; then
	cd ${BUILD_DIR}
	./bootstrap.sh
	build_autotools
    else
	echo "ERROR -> ${BUILD_DIR} no available!"
    fi
}

build_make_install()
{
    if [ -d ${BUILD_DIR} ]; then
	cd ${BUILD_DIR}
	make install
    else
	echo "ERROR -> ${BUILD_DIR} no available!"
    fi
}

install_all()
{
    #
    # build the "./autogen && ./configure ..." repos
    #
    BUILD_DIR=${ARMHF_BIN_HOME}/external/can-utils
    CONFIGURE_ADDS=''
    build_autogen

    #
    # build the "make install" repos
    #
    # BUILD_DIR=${ARMHF_BIN_HOME}/external/lcd160x_driver
    # CONFIGURE_ADDS=''
    # build_make_install

    #
    # build the "./bootstrap && ./configure ..." repos
    #
    BUILD_DIR=${ARMHF_BIN_HOME}/external/libbaalue
    #CONFIGURE_ADDS="--enable-debug-info --enable-examples --enable-lcd160x"
    CONFIGURE_ADDS="--enable-debug-info"
    build_bootstrap

    BUILD_DIR=${ARMHF_BIN_HOME}/external/baalued
    CONFIGURE_ADDS="--enable-debug-info"
    build_bootstrap

    BUILD_DIR=${ARMHF_BIN_HOME}/external/baalue
    CONFIGURE_ADDS="--enable-debug-info"
    build_bootstrap
}

uninstall_all()
{
    #
    # uninstall the autotools repos
    #
    cd ${ARMHF_BIN_HOME}/external/can-utils
    sudo make uninstall

    cd ${ARMHF_BIN_HOME}/external/libbaalue
    sudo make uninstall

    cd ${ARMHF_BIN_HOME}/external/baalued
    sudo make uninstall

    cd ${ARMHF_BIN_HOME}/external/baalue
    sudo make uninstall

    #
    # build the "make install" repos
    #
    # cd ${ARMHF_BIN_HOME}/external/lcd160x_driver
    # sudo make uninstall
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

echo " "
echo "+------------------------------------------+"
echo "| build my base external repositorys       |"
echo "| --> need sudo for some parts             |"
echo "+------------------------------------------+"
echo " "

sudo -v
# keep-alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

if [ "$UNINSTALL" = 'true' ]; then
    uninstall_all
else
    install_all
fi

cleanup

echo " "
echo "+----------------------------------------+"
echo "|            Cheers $USER "
echo "+----------------------------------------+"
echo " "
