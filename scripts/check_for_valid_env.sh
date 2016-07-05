#!/usr/bin/env bash
################################################################################
#
# Title       :    check_for_valid_env.sh
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
# Date/Beginn :    05.07.2016/05.07.2016
#
# Version     :    V1.00
#
# Milestones  :    V1.00 (jul 2016) -> some smaller changes
#                  V0.01 (jul 2016) -> first functional version
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to check if arm_env.sh and $ARMHF_KERNEL* in sync
#
# Some features
#   - ...
#
# Notes
#   - ...
#
################################################################################

# VERSION-NUMBER
VER='1.00'

# if env is sourced
MISSING_ENV='false'


# my usage method
my_usage()
{
    echo " "
    echo "+------------------------------------------+"
    echo "| Usage: ./check_for_valid_env.sh          |"
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
    clear
    echo "+------------------------------------------+"
    echo "|          Cheers $USER                   |"
    echo "+------------------------------------------+"
    cleanup
    exit
}

# print version info
print_version()
{
    echo "+------------------------------------------+"
    echo "| You are using version: ${VER}            |"
    echo "+------------------------------------------+"
    cleanup
    exit
}

# ---- Some values for internal use ----
_temp="/tmp/get_toolchain.$$"
_log="/tmp/get_toolchain.log"


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
# ***                         Main Loop                                      ***
# ******************************************************************************

echo " "
echo "+----------------------------------------+"
echo "|  check if env variable and env script  |"
echo "|  are in sync                           |"
echo "+----------------------------------------+"
echo " "


TMP_STRING=`grep ARMHF_KERNEL_VER ${ARMHF_HOME}/armhf_env | awk -F '[=]' '{print $2}'`
if [ "$TMP_STRING" != "$ARMHF_KERNEL_VER" ]; then
    echo " "
    echo "+---------------- ERROR -----------------+"
    echo "| The versions of ARMHF_KERNEL_VER: ${ARMHF_KERNEL_VER}"
    echo "| and armhf_env: ${TMP_STRING} are different!"
    echo "+----------------------------------------+"
    echo " "
    cleanup
    exit 2
fi

TMP_STRING=`grep ARMHF_RT_KERNEL_VER ${ARMHF_HOME}/armhf_env | awk -F '[=]' '{print $2}'`
if [ "$TMP_STRING" != "$ARMHF_RT_KERNEL_VER" ]; then
    echo " "
    echo "+---------------- ERROR -----------------+"
    echo "| The versions of ARMHF_RT_KERNEL_VER: ${ARMHF_RT_KERNEL_VER}"
    echo "| and armhf_env: ${TMP_STRING} are different!"
    echo "+----------------------------------------+"
    echo " "
    cleanup
    exit 2
fi

TMP_STRING=`grep ARMHF_RT_VER ${ARMHF_HOME}/armhf_env | awk -F '[=]' '{print $2}'`
if [ "$TMP_STRING" != "$ARMHF_RT_VER" ]; then
    echo " "
    echo "+---------------- ERROR -----------------+"
    echo "| The versions of ARMHF_RT_VER: ${ARMHF_RT_VER}"
    echo "| and armhf_env: ${TMP_STRING} are different!"
    echo "+----------------------------------------+"
    echo " "
    cleanup
    exit 2
fi

echo " "
echo "+----------------------------------------+"
echo "| env variable and env script are in sync|"
echo "+----------------------------------------+"
echo " "

cleanup
echo " "
echo "+----------------------------------------+"
echo "|          Cheers $USER                |"
echo "+----------------------------------------+"
echo " "
