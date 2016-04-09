#!/usr/bin/env bash
################################################################################
#
# Title       :    init_sdk.sh    
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
# Date/Beginn :    09.04.2016/25.01.2016
#
# Version     :    V0.04
#
# Milestones  :    V0.04 (apr 2016) -> fix wrong date
#                                      fix user handling for rsync
#                  V0.03 (apr 2016) -> add srcdir
#                  V0.02 (feb 2016) -> init working-dir 
#                  V0.01 (jan 2016) -> first functional version
#
# Requires    :    
#                 
#
################################################################################
# Description
#   
#   A simple tool to init the sdk
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
VER='0.04'

# if env is sourced 
MISSING_ENV='false'

# my usage method 
my_usage() 
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ./init_sdk.sh                                   |"
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
_temp="/tmp/init_sdk.$$"
_log="/tmp/init_sdk.log"


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

if [ "$ARMHF_HOME" = '' ]; then 
    MISSING_ENV='true'
fi

if [ "$ARMHF_BIN_HOME" = '' ]; then 
    MISSING_ENV='true'
fi

if [ "$ARMHF_SRC_HOME" = '' ]; then 
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
echo "|             init the sdk               |"
echo "+----------------------------------------+"
echo " "

if [ -d $ARMHF_BIN_HOME ]; then
    echo "$ARMHF_BIN_HOME already available"
else
    echo "Create $ARMHF_BIN_HOME -> need sudo rights! "
    sudo mkdir -p $ARMHF_BIN_HOME
    sudo chown $USER:users $ARMHF_BIN_HOME
    sudo chmod 775 $ARMHF_BIN_HOME
fi

# check only one makefile -> should be good enough
if [ -f $ARMHF_BIN_HOME/external/Makefile ]; then
    echo "$ARMHF_BIN_HOME/external/Makefile already available"
else
    cd $ARMHF_BIN_HOME
    echo "Rsync content of $ARMHF_HOME/a20_sdk/ to $ARMHF_BIN_HOME"
    rsync -av $ARMHF_HOME/a20_sdk/. .
fi

if [ -d $ARMHF_SRC_HOME ]; then
    echo "$ARMHF_SRC_HOME already available"
else
    echo "Create $ARMHF_SRC_HOME"
    mkdir -p $ARMHF_SRC_HOME
fi

# check only one makefile -> should be good enough
if [ -f $ARMHF_SRC_HOME/include/Makefile ]; then
    echo "$ARMHF_SRC_HOME/include/Makefile already available"
else
    cd $ARMHF_SRC_HOME
    echo "Rsync content of $ARMHF_HOME/a20_sdk_src/ to $ARMHF_SRC_HOME"
    rsync -av $ARMHF_HOME/a20_sdk_src/. .
fi


cleanup
echo " "
echo "+----------------------------------------+"
echo "|          Cheers $USER                |"
echo "+----------------------------------------+"
echo " "
