#!/usr/bin/env bash
################################################################################
#
# Title       :    get_binpkgs.sh
#
# License:
#
# GPL
# (c) 2018, thorsten.johannvorderbrueggen@t-online.de
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
# Date/Beginn :    01.01.2018/01.01.2018
#
# Version     :    V0.01
#
# Milestones  :    V0.01 (jan 2018) -> first functional version
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to download and untar the addtional bin-pkgs to $ARMHF_BIN_HOME  ...
#
# Some features
#   - ...
#
# Notes
#   - binpkgs reside on sourceforge with the following structure
#     "root on sf"
#     -> .
#         -> void-packages
#                  -> binpkgs.tgz
#
################################################################################
#

# VERSION-NUMBER
VER='0.01'

# if env is sourced
MISSING_ENV='false'

# the local build void-packages like emacs-gtk2
DOWNLOAD_STRING="http://sourceforge.net/projects/a20devices/files/void-packages/binpkgs.tgz"

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
echo "+-------------------------------------+"
echo "|  get/install latest binpkgs tarball |"
echo "+-------------------------------------+"
echo " "

cd /tmp

if [ -d $ARMHF_BIN_HOME/binpkgs ]; then
    cd $ARMHF_BIN_HOME/binpkgs
else
    echo "ERROR -> ${ARMHF_BIN_HOME}/binpkgs doesn't exist -> do a make init_sdk" >&2
    my_exit
fi

wget $DOWNLOAD_STRING
if [ $? -ne 0 ] ; then
    echo "ERROR -> could not download ${DOWNLOAD_STRING}" >&2
    my_exit
fi

if [ -f binpkgs.tgz ]; then
    tar xzvf binpkgs.tgz
else
    echo "ERROR -> binpkgs.tgz does not exist" >&2
    my_exit
fi

cleanup
echo " "
echo "+----------------------------------------+"
echo "|            Cheers $USER"
echo "+----------------------------------------+"
echo " "

