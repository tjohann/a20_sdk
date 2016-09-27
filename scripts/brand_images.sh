#!/usr/bin/env bash
################################################################################
#
# Title       :    brand_images.sh
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
# Date/Beginn :    27.09.2016/02.07.2016
#
# Version     :    V2.00
#
# Milestones  :    V2.00 (sep 2016) -> update version info fo A20_SDK_V2.0.0
#                  V1.09 (sep 2016) -> remove arm926_sdk parts
#                  V1.08 (sep 2016) -> add -z to all rsync calls
#                  V1.07 (aug 2016) -> fix owner permissions in /home/baalue
#                  V1.06 (aug 2016) -> sudo handling at beginning
#                  V1.05 (aug 2016) -> copy also hdd_installation to ${SHARED}
#                  V1.04 (aug 2016) -> fix sd-hard handling
#                                      change location for hdd branding
#                                      some more fixes
#                  V1.03 (aug 2016) -> add special branding for baalue
#                                      (clone of arm_cortex_sdk and arm926_sdk)
#                                      be aware of HDD preparation
#                  V1.02 (aug 2016) -> add features of make_sdcard.sh
#                  V1.01 (jul 2016) -> fix missing umount
#                  V1.00 (jul 2016) -> version bump to V1.00
#                  V0.06 (jul 2016) -> some fixes for branding home
#                                      relax error handling due to umount
#                  V0.05 (jul 2016) -> redirect errors to >&2
#                  V0.04 (jul 2016) -> split branding into different dir
#                                      add support for baalue
#                                      change exit code to 3
#                  V0.03 (jul 2016) -> some fixes and improvements
#                  V0.02 (jul 2016) -> first working version
#                  V0.01 (jul 2016) -> initial skeleton
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to brand installed image
#
# Some features
#   - ...
#
# Differences of the images (bananapi is the master!)
#   - *_SDCARD_ROOTFS
#     - hostname
#     - dhcpd.conf
#
################################################################################
#

# VERSION-NUMBER
VER='2.00'

# if env is sourced
MISSING_ENV='false'

# which brand?
BRAND='none'

# mounted images
SD_ROOTFS='none'
SD_HOME='none'
SD_SHARED='none'

# HDD installation?
PREP_HDD_INST='false'

# source for branding
SRC_BRANDING='none'

# program name
PROGRAM_NAME=${0##*/}

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ${PROGRAM_NAME} "
    echo "|        [-b] -> bananapi/bananapi-pro/olimex/baalue/    |"
    echo "|                cubietruck                              |"
    echo "|        [-s] -> prepare images for hdd installation     |"
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
    umount_partitions

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
while getopts 'hvsb:' opts 2>$_log
do
    case $opts in
        h) my_usage ;;
        v) print_version ;;
        b) BRAND=$OPTARG ;;
	s) PREP_HDD_INST='true' ;;
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

if [[ ! ${BANANAPI_SDCARD_ROOTFS} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${OLIMEX_SDCARD_ROOTFS} ]]; then
    MISSING_ENV='true'
fi

if [[ ! ${CUBIETRUCK_SDCARD_ROOTFS} ]]; then
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

umount_partitions()
{
    umount $SD_ROOTFS
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not umount ${SD_ROOTFS}" >&2
    fi

    if [ "$PREP_HDD_INST" = 'true' ]; then
	umount $SD_SHARED
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not umount ${SD_HOME}" >&2
	fi
    else
	umount $SD_HOME
	if [ $? -ne 0 ] ; then
	    echo "INFO -> could not umount ${SD_HOME}" >&2
	fi
    fi
}

brand_image_etc()
{
    local src_branding=${ARMHF_HOME}/${BRAND}/branding/etc

    if [ -d ${src_branding} ]; then
	if [[ ! -d "${SD_ROOTFS}" ]]; then
	    echo "ERROR -> ${SD_ROOTFS} not available!" >&2
	    echo "         have you added them to your fstab? (see README.md)" >&2
	    my_usage
	fi

	mountpoint $SD_ROOTFS
	if [ $? -ne 0 ] ; then
	    echo "${SD_ROOTFS} not mounted, i try it now"
	    mount $SD_ROOTFS
	    if [ $? -ne 0 ] ; then
		echo "ERROR -> could not mount ${SD_ROOTFS}" >&2
		my_exit
	    fi
	fi

	if [[ ! -d "${SD_ROOTFS}/etc" ]]; then
	    echo "ERROR -> ${SD_ROOTFS}/etc not available ... abort now!" >&2
	    my_exit
	fi

	echo "sudo rsync -avz ${src_branding}/. ${SD_ROOTFS}/etc/."
	sudo rsync -avz ${src_branding}/. ${SD_ROOTFS}/etc/.
    else
	echo "INFO: no dir ${src_branding}, so no branding for ${BRAND}"
    fi
}

brand_image_home()
{
    local src_branding=${ARMHF_HOME}/${BRAND}/branding/home

    if [ -d ${src_branding} ]; then
	if [[ ! -d "${SD_HOME}" ]]; then
	    echo "ERROR -> ${SD_HOME} not available!"
	    echo "         have you added them to your fstab? (see README.md)"
	    my_usage
	fi

	mountpoint $SD_HOME
	if [ $? -ne 0 ] ; then
	    echo "${SD_HOME} not mounted, i try it now"
	    mount $SD_HOME
	    if [ $? -ne 0 ] ; then
		echo "ERROR -> could not mount ${SD_HOME}"
		my_exit
	    fi
	fi

	if [[ ! -d "${SD_HOME}/baalue" ]]; then
	    echo "ERROR -> ${SD_HOME}/baalue not available ... abort now!"
	    my_exit
	fi

	echo "sudo rsync -avz --delete ${src_branding}/. ${SD_HOME}/baalue/."
	sudo rsync -avz --delete ${src_branding}/. ${SD_HOME}/baalue/.
	sudo chown -R 1000:1000 ${SD_HOME}/baalue
    else
	echo "INFO: no dir ${src_branding}, so no branding for ${BRAND}"
    fi
}

brand_baalue()
{
    mountpoint $SD_HOME
    if [ $? -ne 0 ] ; then
	echo "${SD_HOME} not mounted, i try it now"
	mount $SD_HOME
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not mount ${SD_HOME}"
	    my_exit
	fi
    fi

    if [ -d ${SD_HOME}/baalue/arm_cortex_sdk ]; then
	echo "${SD_HOME}/baalue/arm_cortex_sdk already exists -> do a pull"
	cd ${SD_HOME}/baalue/arm_cortex_sdk
	git pull
	cd -
    else
	local repo_name="https://github.com/tjohann/arm_cortex_sdk.git"
	echo "start to clone repo $repo_name"
	sudo git clone $repo_name ${SD_HOME}/baalue/arm_cortex_sdk
	if [ $? -ne 0 ] ; then
	    echo "ERROR: could not clone ${repo_name}" >&2
	    my_exit
	else
	    sudo chown -R 1000:1000 ${SD_HOME}/baalue/arm_cortex_sdk
	fi
    fi
}

brand_image_shared()
{
    local src_branding=${ARMHF_HOME}/${BRAND}/branding/

    if [ -d ${src_branding} ]; then
	if [[ ! -d "${SD_SHARED}" ]]; then
	    echo "ERROR -> ${SD_SHARED} not available!"
	    echo "         have you added them to your fstab? (see README.md)"
	    my_usage
	fi

	mountpoint $SD_SHARED
	if [ $? -ne 0 ] ; then
	    echo "${SD_SHARED} not mounted, i try it now"
	    mount $SD_SHARED
	    if [ $? -ne 0 ] ; then
		echo "ERROR -> could not mount ${SD_SHARED}"
		my_exit
	    fi
	fi

	echo "sudo cp ${src_branding}/hdd_branding.tgz ${SD_SHARED}"
	sudo cp ${src_branding}/hdd_branding.tgz ${SD_SHARED}
	if [ $? -ne 0 ] ; then
	    echo "ERROR: could not copy ${src_branding}/hdd_branding.tgz" >&2
	    my_exit
	fi

	sudo cp ${ARMHF_HOME}/scripts/hdd_installation.sh ${SD_SHARED}
	if [ $? -ne 0 ] ; then
	    echo "ERROR: could not copy ${ARMHF_HOME}/scripts/hdd_installation.sh" >&2
	    my_exit
	fi
    else
	echo "INFO: no dir ${src_branding}, so no branding for ${BRAND}"
    fi
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

# sudo handling up-front
echo " "
echo "+------------------------------------------+"
echo "| brand installed device image             |"
echo "| --> need sudo for some parts             |"
echo "+------------------------------------------+"
echo " "

sudo -v
# keep-alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

#
# order of branding:
# - etc
# - home (simple rsync parts)
# - device specific (see brand_baalue as example)
#
case "$BRAND" in
    'bananapi')
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
	SD_HOME=$BANANAPI_SDCARD_HOME
	SD_SHARED=$BANANAPI_SDCARD_SHARED
        ;;
    'bananapi-pro')
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
	SD_HOME=$BANANAPI_SDCARD_HOME
	SD_SHARED=$BANANAPI_SDCARD_SHARED
        ;;
    'baalue')
	SD_ROOTFS=$BANANAPI_SDCARD_ROOTFS
	SD_HOME=$BANANAPI_SDCARD_HOME
	SD_SHARED=$BANANAPI_SDCARD_SHARED
	;;
    'olimex')
	SD_ROOTFS=$OLIMEX_SDCARD_ROOTFS
	SD_HOME=$OLIMEX_SDCARD_HOME
	SD_SHARED=$OLIMEX_SDCARD_SHARED
        ;;
    'cubietruck')
	SD_ROOTFS=$CUBIETRUCK_SDCARD_ROOTFS
	SD_HOME=$CUBIETRUCK_SDCARD_HOME
	SD_SHARED=$CUBIETRUCK_SDCARD_SHARED
        ;;
    *)
        echo "ERROR -> ${BRAND} is not supported ... pls check" >&2
        my_usage
esac

brand_image_etc
if [ "$PREP_HDD_INST" = 'true' ]; then
    brand_image_shared
else
    brand_image_home

    # special handling needed for baalue
    if [ "$BRAND" = 'baalue' ]; then
	brand_baalue
    fi
fi

umount_partitions
cleanup

echo " "
echo "+----------------------------------------+"
echo "|            Cheers $USER "
echo "+----------------------------------------+"
echo " "
