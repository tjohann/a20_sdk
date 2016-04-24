#!/usr/bin/env bash
################################################################################
#
# Title       :    get_image_tarballs.sh    
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
# Date/Beginn :    24.04.2016/24.08.2015
#
# Version     :    V0.10
#
# Milestones  :    V0.10 (apr 2016) -> add baalue 
#                  V0.09 (apr 2016) -> add cubietruck-hdd
#                                      add bananapi-pro-hdd
#                                      remove unused comment
#                                      fix wrong image names 
#                  V0.08 (apr 2016) -> create $ARMHF_BIN_HOME/* if it not exist
#                  V0.07 (apr 2016) -> check for architecture
#                                      some more error checks/cleanups
#                  V0.06 (mar 2016) -> add missing check for dir 
#                  V0.05 (jan 2016) -> implement new architecture
#                  V0.04 (jan 2016) -> add bananapi-pro as device
#                  V0.03 (jan 2016) -> fix missing help content
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
VER='0.10'

# if env is sourced 
MISSING_ENV='false'

# supported devices
BAALUE='false'
BANANAPI='false'
BANANAPIPRO='false'
BANANAPIPRO_HDD='false'
CUBIETRUCK='false'
CUBIETRUCK_HDD='false'
OLIMEX='false'

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
    echo "|        [-a] -> download ALL images                     |"
    echo "|        [-b] -> download bananapi images                |"
    echo "|        [-f] -> download baalue cluster images          |"
    echo "|        [-p] -> download bananapi-pro images            |"
    echo "|        [-e] -> download bananapi-pro-hdd images        |"
    echo "|        [-c] -> download cubietruck images              |"
    echo "|        [-d] -> download cubietruck-hdd images          |"
    echo "|        [-o] -> download olimex images                  |"
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
while getopts 'bcdefopahv' opts 2>$_log
do
    case $opts in
	f) BAALUE='true' ;;
	b) BANANAPI='true' ;;
	c) CUBIETRUCK='true' ;;
	d) CUBIETRUCK_HDD='true' ;;
	o) OLIMEX='true' ;;
	p) BANANAPIPRO='true' ;;
	e) BANANAPIPRO_HDD='true' ;;
	a) OLIMEX='true'
	   BANANAPI='true'
	   BAALUE='true' ;;
	   BANANAPI_HDD='true'
	   CUBIETRUCK='true'
	   CUBIETRUCK_HDD='true'
	   BANANAPIPRO='true'
	   ;;
        h) my_usage ;;
	v) print_version ;;
        ?) my_usage ;;
    esac
done


# ******************************************************************************
# ***             Error handling for missing shell values                    ***
# ******************************************************************************

if [ "$ARMHF_BIN_HOME" = '' ]; then 
    MISSING_ENV='true'
fi

# show a usage screen and exit
if [ "$MISSING_ENV" = 'true' ]; then 
    cleanup
    clear
    echo " "
    echo "+------------------------------------------+"
    echo "|                                          |"
    echo "|  ERROR: missing env                      |"
    echo "|         have you sourced env-file?       |"
    echo "|                                          |"
    echo "|          Cheers $USER                   |"
    echo "|                                          |"
    echo "+------------------------------------------+"
    echo " "
    exit
fi


# ******************************************************************************
# ***                      The functions for main_menu                       ***
# ******************************************************************************


# --- create download string 
create_download_string_bananapi()
{
    KERNEL_IMAGE="http://sourceforge.net/projects/a20devices/files/bananapi/bananapi_home.tgz"
    ROOTFS_IMAGE="http://sourceforge.net/projects/a20devices/files/bananapi/bananapi_rootfs.tgz"
    HOME_IMAGE="http://sourceforge.net/projects/a20devices/files/bananapi/bananapi_home.tgz"
    
    echo "INFO: set kernel download string to $KERNEL_IMAGE"
    echo "INFO: set rootfs download string to $ROOTFS_IMAGE"
    echo "INFO: set home download string to $HOME_IMAGE"
}

# --- create download string 
create_download_string_baalue()
{
    KERNEL_IMAGE="http://sourceforge.net/projects/a20devices/files/bananapi/baalue_kernel.tgz"
    ROOTFS_IMAGE="http://sourceforge.net/projects/a20devices/files/bananapi/baalue_rootfs.tgz"
    HOME_IMAGE="http://sourceforge.net/projects/a20devices/files/bananapi/bananapi_home.tgz"
    
    echo "INFO: set kernel download string to $KERNEL_IMAGE"
    echo "INFO: set rootfs download string to $ROOTFS_IMAGE"
    echo "INFO: set home download string to $HOME_IMAGE"
}

# --- create download string 
create_download_string_bananapi-pro()
{
    KERNEL_IMAGE="http://sourceforge.net/projects/a20devices/files/bananapi/bananapi-pro_kernel.tgz"
    ROOTFS_IMAGE="http://sourceforge.net/projects/a20devices/files/bananapi/bananapi-pro_rootfs.tgz"
    HOME_IMAGE="http://sourceforge.net/projects/a20devices/files/bananapi/bananapi-pro_home.tgz"
    
    echo "INFO: set kernel download string to $KERNEL_IMAGE"
    echo "INFO: set rootfs download string to $ROOTFS_IMAGE"
    echo "INFO: set home download string to $HOME_IMAGE"
}

# --- create download string 
create_download_string_bananapi-pro_hdd()
{
    KERNEL_IMAGE="http://sourceforge.net/projects/a20devices/files/bananapi/bananapi-pro_hdd_kernel.tgz"
    ROOTFS_IMAGE="http://sourceforge.net/projects/a20devices/files/bananapi/bananapi-pro_hdd_rootfs.tgz"
    HOME_IMAGE="http://sourceforge.net/projects/a20devices/files/bananapi/bananapi-pro_home.tgz"
    
    echo "INFO: set kernel download string to $KERNEL_IMAGE"
    echo "INFO: set rootfs download string to $ROOTFS_IMAGE"
    echo "INFO: set home download string to $HOME_IMAGE"
}

# --- create download string 
create_download_string_cubietruck()
{
    KERNEL_IMAGE="http://sourceforge.net/projects/a20devices/files/cubietruck/cubietruck_kernel.tgz"
    ROOTFS_IMAGE="http://sourceforge.net/projects/a20devices/files/cubietruck/cubietruck_rootfs.tgz"
    HOME_IMAGE="http://sourceforge.net/projects/a20devices/files/cubietruck/cubietruck_home.tgz"
    
    echo "INFO: set kernel download string to $KERNEL_IMAGE"
    echo "INFO: set rootfs download string to $ROOTFS_IMAGE"
    echo "INFO: set home download string to $HOME_IMAGE"
}

# --- create download string 
create_download_string_cubietruck_hdd()
{
    KERNEL_IMAGE="http://sourceforge.net/projects/a20devices/files/cubietruck/cubietruck_hdd_kernel.tgz"
    ROOTFS_IMAGE="http://sourceforge.net/projects/a20devices/files/cubietruck/cubietruck_hdd_rootfs.tgz"
    HOME_IMAGE="http://sourceforge.net/projects/a20devices/files/cubietruck/cubietruck_home.tgz"
    
    echo "INFO: set kernel download string to $KERNEL_IMAGE"
    echo "INFO: set rootfs download string to $ROOTFS_IMAGE"
    echo "INFO: set home download string to $HOME_IMAGE"
}

# --- create download string 
create_download_string_olimex()
{
    KERNEL_IMAGE="http://sourceforge.net/projects/a20devices/files/olimex/olimex_kernel.tgz"
    ROOTFS_IMAGE="http://sourceforge.net/projects/a20devices/files/olimex/olimex_rootfs.tgz"
    HOME_IMAGE="http://sourceforge.net/projects/a20devices/files/olimex/olimex_home.tgz"
    
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
echo "+----------------------------------------------+"
echo "|  dowload latest image tarballs               |"
echo "+----------------------------------------------+"
echo " "

if [ $(uname -m) == 'x86_64' ]; then

    if [ -d $ARMHF_BIN_HOME/images ]; then
	cd $ARMHF_BIN_HOME/images
    else
	mkdir -p $ARMHF_BIN_HOME/images
	cd $ARMHF_BIN_HOME/images
    fi
    
    if [ "$BANANAPI" = 'true' ]; then 
	create_download_string_bananapi
	get_image_tarball
    fi

    if [ "$BAALUE" = 'true' ]; then 
	create_download_string_baalue
	get_image_tarball
    fi
    
    if [ "$BANANAPIPRO" = 'true' ]; then 
	create_download_string_bananapi-pro
	get_image_tarball
    fi

    if [ "$BANANAPIPRO_HDD" = 'true' ]; then 
	create_download_string_bananapi-pro_hdd
	get_image_tarball
    fi
    
    if [ "$CUBIETRUCK" = 'true' ]; then 
	create_download_string_cubietruck
	get_image_tarball
    fi

    if [ "$CUBIETRUCK_HDD" = 'true' ]; then 
	create_download_string_cubietruck_hdd
	get_image_tarball
    fi
    
    if [ "$OLIMEX" = 'true' ]; then 
	create_download_string_olimex
	get_image_tarball
    fi  
else
    echo "INFO: image handling on $(uname -m) not supported"
fi

cleanup
echo " "
echo "+----------------------------------------+"
echo "|          Cheers $USER                |"
echo "+----------------------------------------+"
echo " "
