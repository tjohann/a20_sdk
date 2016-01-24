#!/usr/bin/env bash
################################################################################
#
# Title       :    get_image_tarballs.sh    
#
# License:
#
# GPL                                                                        
# (c) 2015, thorsten.johannvorderbrueggen@t-online.de                        
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
# Date/Beginn :    24.01.2016/24.08.2015
#
# Version     :    V0.03
#
# Milestones  :    V0.03 (jan 2016) -> 
#                  V0.02 (jan 2016) -> adapt for usage in a20_sdk
#                                      add support for olimex
#                                      add support for cubietruck
#                  V0.01 (aug 2015) -> first functional version
#
# Requires    :    
#                 
#
################################################################################
# Description
#   
#   A simple tool to download the image tarballs  
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
VER='0.02'

# if env is sourced 
MISSING_ENV='false'

# supported devices
BANANAPI='false'
CUBIETRUCK='true'
OLIMEX='true'

#
# latest version bananapi 
#
# VER:
# -> kernel_bananapi.tgz
# -> rootfs_bananapi.tgz
# -> home_bananapi.tgz
#
# DOWNLOAD_STRING:
# -> http://sourceforge.net/projects/a20devices/files/bananapi/kernel_bananapi.tgz
# -> http://sourceforge.net/projects/a20devices/files/bananapi/rootfs_bananapi.tgz
# -> http://sourceforge.net/projects/a20devices/files/bananapi/home_bananapi.tgz
#

#
# latest version cubietruck 
#
# VER:
# -> kernel_cubietruck.tgz
# -> rootfs_cubietruck.tgz
# -> home_cubietruck.tgz
#
# DOWNLOAD_STRING:
# -> http://sourceforge.net/projects/a20devices/files/cubietruck/kernel_cubietruck.tgz
# -> http://sourceforge.net/projects/a20devices/files/cubietruck/rootfs_cubietruck.tgz
# -> http://sourceforge.net/projects/a20devices/files/cubietruck/home_cubietruck.tgz
#

#
# latest version olimex 
#
# VER:
# -> kernel_olimex.tgz
# -> rootfs_olimex.tgz
# -> home_olimex.tgz
#
# DOWNLOAD_STRING:
# -> http://sourceforge.net/projects/a20devices/files/olimex/kernel_olimex.tgz
# -> http://sourceforge.net/projects/a20devices/files/olimex/rootfs_olimex.tgz
# -> http://sourceforge.net/projects/a20devices/files/olimex/home_olimex.tgz
#

# actual set nothing
KERNEL_IMAGE='none'
ROOTFS_IMAGE='none'
HOME_IMAGE='none'


# my usage method 
my_usage() 
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ./get_image_tarballs.sh                         |"
    echo "|        [-v] -> print version info                      |"
    echo "|        [-h] -> this help                               |"
    echo "|        [-b] -> download bananapi images                |"
    echo "|        [-h] -> download cubietruck images              |"
    echo "|        [-h] -> download olimex images                  |"
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
_temp="/tmp/get_image_tarballs.$$"
_log="/tmp/get_image_tarballs.log"


# check the args 
while getopts 'hvabco' opts 2>$_log
do
    case $opts in
	b) BANANAPI='true' ;;
	c) CUBIETRUCK='true' ;;
	o) OLIMEX='true' ;;
	a) OLIMEX='true'
	   BANANAPI='true'
	   CUBIETRUCK='true'
	   ;;
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


# --- create download string 
create_download_string_bananapi()
{
    KERNEL_IMAGE="http://sourceforge.net/projects/a20devices/files/bananapi/kernel_bananapi.tgz"
    ROOTFS_IMAGE="http://sourceforge.net/projects/a20devices/files/bananapi/rootfs_bananapi.tgz"
    HOME_IMAGE="http://sourceforge.net/projects/a20devices/files/bananapi/home_bananapi.tgz"
    
    echo "INFO: set kernel download string to $KERNEL_IMAGE"
    echo "INFO: set rootfs download string to $ROOTFS_IMAGE"
    echo "INFO: set home download string to $HOME_IMAGE"
}


# --- create download string 
create_download_string_cubietruck()
{
    KERNEL_IMAGE="http://sourceforge.net/projects/a20devices/files/cubietruck/kernel_cubietruck.tgz"
    ROOTFS_IMAGE="http://sourceforge.net/projects/a20devices/files/cubietruck/rootfs_cubietruck.tgz"
    HOME_IMAGE="http://sourceforge.net/projects/a20devices/files/cubietruck/home_cubietruck.tgz"
    
    echo "INFO: set kernel download string to $KERNEL_IMAGE"
    echo "INFO: set rootfs download string to $ROOTFS_IMAGE"
    echo "INFO: set home download string to $HOME_IMAGE"
}


# --- create download string 
create_download_string_olimex()
{
    KERNEL_IMAGE="http://sourceforge.net/projects/a20devices/files/olimex/kernel_olimex.tgz"
    ROOTFS_IMAGE="http://sourceforge.net/projects/a20devices/files/olimex/rootfs_olimex.tgz"
    HOME_IMAGE="http://sourceforge.net/projects/a20devices/files/olimex/home_olimex.tgz"
    
    echo "INFO: set kernel download string to $KERNEL_IMAGE"
    echo "INFO: set rootfs download string to $ROOTFS_IMAGE"
    echo "INFO: set home download string to $HOME_IMAGE"
}


# --- download image tarball
get_image_tarball()
{
    if [ "$KERNEL_IMAGE" = 'none' ]; then 
	echo " "
	echo "+--------------------------------------+"
	echo "|                                      |"
	echo "|  ERROR: KERNEL_IMAGE is  none!       |"
	echo "|                                      |"
	echo "+--------------------------------------+"
	echo " "

	cleanup
    fi 

    if [ "$ROOTFS_IMAGE" = 'none' ]; then 
	echo " "
	echo "+--------------------------------------+"
	echo "|                                      |"
	echo "|  ERROR: ROOTFS_IMAGE is  none!       |"
	echo "|                                      |"
	echo "+--------------------------------------+"
	echo " "

	cleanup
    fi

    if [ "$HOME_IMAGE" = 'none' ]; then 
	echo " "
	echo "+--------------------------------------+"
	echo "|                                      |"
	echo "|  ERROR: HOME_IMAGE is  none!         |"
	echo "|                                      |"
	echo "+--------------------------------------+"
	echo " "

	cleanup
    fi 

    wget $KERNEL_IMAGE
    wget $ROOTFS_IMAGE
    wget $HOME_IMAGE

    # clear all
    KERNEL_IMAGE='none'
    ROOTFS_IMAGE='none'
    HOME_IMAGE='none'
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ****************************************************************************** 

echo " "
echo "+----------------------------------------+"
echo "|  dowload latest image tarballs         |"
echo "+----------------------------------------+"
echo " "

cd $ARMHF_HOME/images

if [ "$BANANAPI" = 'true' ]; then 
    create_download_string_bananapi
    get_image_tarball
fi

if [ "$CUBIETRUCK" = 'true' ]; then 
    create_download_string_cubietruck
    get_image_tarball
fi

if [ "$OLIMEX" = 'true' ]; then 
    create_download_string_olimex
    get_image_tarball
fi


cleanup
echo " "
echo "+----------------------------------------+"
echo "|          Cheers $USER                |"
echo "+----------------------------------------+"
echo " "


############################# END OF ALL TIMES :-) ##############################
