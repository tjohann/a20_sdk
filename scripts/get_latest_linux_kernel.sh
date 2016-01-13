#!/usr/bin/env bash
################################################################################
#
# Title       :    get_latest_linux_kernel.sh 
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
# Date/Beginn :    13.01.2016/15.08.2015
#
# Version     :    V0.02
#
# Milestones  :    V0.02 (jan 2016) -> adapt it for usage within a20_sdk
#                  V0.01 (aug 2015) -> first functional version
#
# Requires    :    ...
#                 
#
################################################################################
# Description
#   
#   A simple tool to get the latest kernel tarball and copy it to
#   $ARMHF_HOME/kernel ...  
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

# latest kernel/rt-preempt version
KERNEL_VER='none'
RT_KERNEL_VER='none'
DOWNLOAD_STRING='none'

# my usage method 
my_usage() 
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ./get_latest_linux_kernel.sh                    |"
    echo "|        [-v] -> print version info                      |"
    echo "|        [-h] -> this help                               |"
    echo "|                                                        |"
    echo "| This small tool download based on the values of        |"
    echo "| ARMHF_KERNEL_VER, ARMHF_RT_KERNEL_VER and              |"
    echo "| ARMHF_RT_VER the needed source files to build a        |"
    echo "| custom kernel.                                         |"
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
_temp="/tmp/get_latest_linux_kernel.$$"
_log="/tmp/get_latest_linux_kernel.log"


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

if [ "$ARMHF_KERNEL_VER" = '' ]; then 
    MISSING_ENV='true'
fi

if [ "$ARMHF_RT_KERNEL_VER" = '' ]; then 
    MISSING_ENV='true'
fi

if [ "$ARMHF_RT_VER" = '' ]; then 
    MISSING_ENV='true'
fi

# show a usage screen and exit
if [ "$MISSING_ENV" = 'true' ]; then 
    cleanup
    clear
    echo " "
    echo "+--------------------------------------+"
    echo "|  ERROR: missing env                  |"
    echo "|         have you sourced env-file?   |"
    echo "+--------------------------------------+"
    echo " "
    exit
fi


# ******************************************************************************
# ***                      The functions for main_menu                       ***
# ******************************************************************************

# --- get the kernel sources
get_kernel_source()
{
    DOWNLOAD_STRING="https://www.kernel.org/pub/linux/kernel/v4.x/linux-${KERNEL_VER}.tar.xz"
    echo "INFO: set kernel download string to $DOWNLOAD_STRING"
    
    if [ -f linux-${KERNEL_VER}.tar.xz ]; then
	echo " "
	echo "+--------------------------------------+"
	echo "|  INFO: linux-${KERNEL_VER}.tar.xz    |"
	echo "|        already exist, wont download  |"
	echo "|        again                         |"
	echo "+--------------------------------------+"
	echo " "
	
	tar xvf linux-${KERNEL_VER}.tar.xz 
    else
	wget $DOWNLOAD_STRING
	
	if [ $? -ne 0 ]; then
	    echo " "
	    echo "+--------------------------------------+"
	    echo "|  ERROR: cant download!               |"
	    echo "+--------------------------------------+"
	    echo " "

	    cleanup
	else
	   tar xvf linux-${KERNEL_VER}.tar.xz  
	fi
    fi

    # reset value
    DOWNLOAD_STRING='none'
}

# --- get the rt-preempt patch sources
get_rt_patch_source()
{
    DOWNLOAD_STRING="https://www.kernel.org/pub/linux/kernel/projects/rt/4.1/patch-${KERNEL_VER}-${ARMHF_RT_VER}.patch.gz"
    echo "INFO: set rt-preempt patch download string to $DOWNLOAD_STRING"

    if [ -f patch-${KERNEL_VER}-${ARMHF_RT_VER}.patch.gz ]; then
	echo " "
	echo "+--------------------------------------+"
	echo "|  INFO: patch-${KERNEL_VER}-${ARMF_RT_VER}.patch.gz   |"
	echo "|        already exist, wont download  |"
	echo "|        again                         |"
	echo "+--------------------------------------+"
	echo " "
    else	
	wget $DOWNLOAD_STRING
	
	if [ $? -ne 0 ]; then
	    echo " "
	    echo "+--------------------------------------+"
	    echo "|  INFO: cant download using dir older |"
	    echo "+--------------------------------------+"
	    echo " "
	    
	    DOWNLOAD_STRING="https://www.kernel.org/pub/linux/kernel/projects/rt/4.1/older/patch-${KERNEL_VER}-${ARMHF_RT_VER}.patch.gz"
	    echo "INFO: set rt-preempt patch download string to $DOWNLOAD_STRING"

	    wget $DOWNLOAD_STRING

	    if [ $? -ne 0 ]; then
		echo " "
		echo "+--------------------------------------+"
		echo "|  ERROR: cant download patch-${KERNEL_VER}-${ARMHF_RT_VER}.patch.gz |"
		echo "+--------------------------------------+"
		echo " "

		cleanup
	    fi
	fi    
    fi
	
    # reset value
    DOWNLOAD_STRING='none'
}




# ******************************************************************************
# ***                         Main Loop                                      ***
# ****************************************************************************** 

echo " "
echo "+----------------------------------------+"
echo "|       get/install kernel source        |"
echo "+----------------------------------------+"
echo " "

cd $ARMHF_HOME/kernel

# PREEMPT handling
KERNEL_VER=$ARMHF_KERNEL_VER
get_kernel_source

# download only one if rt-preempt patch supports same kernel version
if [ "$ARMHF_KERNEL_VER" = "$ARMHF_RT_KERNEL_VER" ]; then
    echo "INFO: set kernel version for PREEMPT and FULL_RT_PREEMPT are identical"
else
    # FULL_RT_PREEMPT handling
    KERNEL_VER=$ARMHF_RT_KERNEL_VER
    echo "INFO: set kernel version to linux-$KERNEL_VER and linux-$RT_KERNEL_VER "
    get_kernel_source
fi

# rt-preempt patch handling
# note: get_rt_patch_source also use KERNEL_VER 
get_rt_patch_source


cleanup
echo " "
echo "+----------------------------------------+"
echo "|          Cheers $USER                |"
echo "+----------------------------------------+"
echo " "


############################# END OF ALL TIMES :-) ##############################

