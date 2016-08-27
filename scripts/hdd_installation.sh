#!/usr/bin/env bash
################################################################################
#
# Title       :    hdd_installation.sh
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
# Date/Beginn :    27.08.2016/15.08.2016
#
# Version     :    V0.05
#
# Milestones  :    V0.05 (aug 2016) -> some smaller fixes
#                  V0.04 (aug 2016) -> first working version
#                  V0.03 (aug 2016) -> first content
#                  V0.02 (aug 2016) -> some documentation
#                  V0.01 (jul 2016) -> initial skeleton
#
# Requires    :
#
################################################################################
# Description
#
#   A simple tool to do the hdd installation based on a standard
#   sd-card-hdd-inst.
#
# Some features
#   - ...
#
# Step 1:
#   - ceate hdd preparation sd-card (make_sdcard.sh)
# Step 2:
#   - mount /mnt/bananapi/bananapi_shared
#   - partition sda (sda1 -> / and sda2 /home)
#   - format both
#   - mount /dev/sda1 /mnt/tmp
#   - untar /mnt/banan../...rootfs.tgz
#   - untar hdd_branding to /mnt/tmp/etc
#   - umount /dev/sda1
#   - mount /dev/sda2
#   - untar /mnt/ban.../...home.tgz
#   - umount /dev/sda2
#
# Step 3:
#   - create hdd-boot-only sd-card (make_sdcard.sh)
#
################################################################################
#

# VERSION-NUMBER
VER='0.05'

# if env is sourced
MISSING_ENV='false'

# device node (sda1 -> rootfs ... sda2 -> home)
DEVNODE="/dev/sda"

# mountpoint
SD_SHARED="/mnt/bananapi/bananapi_shared"
HDD_TMP="/mnt/tmp"

# ...
TARBALL='none'
BASE_IMAGE='false'

# program name
PROGRAM_NAME=${0##*/}

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "|                                                        |"
    echo "| Usage: ${PROGRAM_NAME} "
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
while getopts 'hv' opts 2>$_log
do
    case $opts in
        h) my_usage ;;
        v) print_version ;;
        ?) my_usage ;;
    esac
done


# ******************************************************************************
# ***                      The functions for main_menu                       ***
# ******************************************************************************

check_devnode()
{
    local mounted=`grep ${DEVNODE} /proc/mounts | sort | cut -d ' ' -f 1`
    if [[ "${mounted}" ]]; then
	echo "ERROR: ${DEVNODE} has already mounted partitions" >&2
	my_exit
    fi
}

check_mountpoints()
{
    if [[ ! -d "${SD_SHARED}" ]]; then
	echo "ERROR -> ${SD_SHARED} not available!" >&2
	my_exit
    fi

    if [[ ! -d "${HDD_TMP}" ]]; then
	echo "ERROR -> ${HDD_TMP} not available!" >&2
	my_exit
    fi
}

umount_partitions()
{
    echo "sudo umount $HDD_TMP"
    sudo umount $HDD_TMP
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not umount ${HDD_TMP}" >&2
	# do not exit -> will try to umount the others
    fi
}

check_tarballs()
{
    if [[ ! -f "${SD_SHARED}/a20_sdk_home.tgz" ]]; then
	echo "ERROR -> ${SD_SHARED}/a20_sdk_home.tgz not available!" >&2
	my_exit
    fi

    local missing_rootfs='true'

    if [[ -f "${SD_SHARED}/a20_sdk_base_rootfs.tgz" ]]; then
	BASE_IMAGE='true'
	missing_rootfs='false'
    fi

    if [[ -f "${SD_SHARED}/a20_sdk_rootfs.tgz" ]]; then
	BASE_IMAGE='false'
	missing_rootfs='false'
    fi

    if [ "$missing_rootfs" = 'true' ]; then
	echo "ERROR -> no rootfs available!" >&2
	my_exit
    fi

    # TODO: check for the rest
}

clean_hdd()
{
    echo "sudo dd if=/dev/zero of=${DEVNODE} bs=1k count=1023 seek=1"
    sudo dd if=/dev/zero of=${DEVNODE} bs=1k count=1023 seek=1
    if [ $? -ne 0 ] ; then
	echo "ERROR: could not clear ${DEVNODE}" >&2
	my_exit
    fi
}

partition_hdd()
{
    sudo blockdev --rereadpt ${DEVNODE}
    cat <<EOT | sudo sfdisk ${DEVNODE}
1M,10G,L
,,L
EOT

    if [ $? -ne 0 ] ; then
	echo "ERROR: could not create partitions" >&2
	my_exit
    fi
}

format_partitions()
{
    if [[ -b ${DEVNODE}1 ]]; then
	echo "sudo mkfs.ext4 ${DEVNODE}1"
	sudo mkfs.ext4 ${DEVNODE}1
	if [ $? -ne 0 ] ; then
	    echo "ERROR: could not format parition ${DEVNODE}1" >&2
	    my_exit
	fi
    else
	echo "ERROR -> ${DEVNODE}1 not available" >&2
	my_exit
    fi

    if [[ -b ${DEVNODE}2 ]]; then
	echo "sudo mkfs.ext4 ${DEVNODE}2"
	sudo mkfs.ext4 ${DEVNODE}2
	if [ $? -ne 0 ] ; then
	    echo "ERROR: could not format parition ${DEVNODE}2" >&2
	    my_exit
	fi
    else
	echo "ERROR -> ${DEVNODE}2 not available" >&2
	my_exit
    fi
}

mount_hdd_tmp()
{
    echo "sudo mount $DEVNODE $HDD_TMP"
    sudo mount $DEVNODE $HDD_TMP
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not mount ${DEVNODE} to ${HDD_TMP}" >&2
	my_exit
    fi
}

untar_image()
{
    echo "sudo tar xzpvf ${TARBALL}"
    sudo tar xzpvf ${TARBALL}
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not untar ${TARBALL}" >&2
	my_exit
    fi
}

# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

# sudo handling up-front
echo " "
echo "+------------------------------------------+"
echo "| hdd installatio script                   |"
echo "| --> need sudo for some parts             |"
echo "+------------------------------------------+"
echo " "

sudo -v
# keep-alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

check_devnode
check_mountpoints
check_tarballs

# create partitions ...
clean_hdd
partition_hdd
format_partitions

# rootfs
DEVNODE="/dev/sda1"
mount_hdd_tmp
cd $HDD_TMP
if [ "$BASE_IMAGE" = 'true' ]; then
    TARBALL="${SD_SHARED}/a20_sdk_base_rootfs.tgz"
else
    TARBALL="${SD_SHARED}/a20_sdk_rootfs.tgz"
fi
untar_image

# branding etc
cd $SD_SHARED
TARBALL="${SD_SHARED}/hdd_branding.tgz"
untar_image
echo "cp -f ${SD_SHARED}/hdd_branding/* ${HDD_TMP}/etc/"
sudo cp -f ${SD_SHARED}/hdd_branding/* ${HDD_TMP}/etc/
if [ $? -ne 0 ] ; then
    echo "ERROR -> could not copy hdd_branding parts" >&2
    my_exit
fi

# home
DEVNODE="/dev/sda2"
mount_hdd_tmp
cd $HDD_TMP
TARBALL="${SD_SHARED}/a20_sdk_home.tgz"
untar_image
cd $SD_SHARED

umount_partitions

cleanup
echo " "
echo "+------------------------------------------+"
echo "|             Cheers $USER                  "
echo "+------------------------------------------+"
echo " "
