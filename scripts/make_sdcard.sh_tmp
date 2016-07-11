#!/usr/bin/env bash

if [ "${BAALUE_HOME}" == "" ]; then
    echo "error: please source baalue_env first!"
    exit -1
fi

function menu()
{
    local prompt=$1
    declare -a options=(${!2})

    PS3="$prompt (or 0 to exit): "
    select opt in "${options[@]}"; do
    echo $opt
    break
    done
}

function get_removable_drives()
{
    echo $(
	grep -Hv ^0$ /sys/block/*/removable |
	sed s/removable:.*$/device\\/uevent/ |
	xargs grep -H ^DRIVER=sd |
	sed s/device.uevent.*$/size/ |
	xargs grep -Hv ^0$ |
	cut -d / -f 4
    )

}

function print_drive_details()
{
    local drives=$1
    local paths=${drives[@]/#/\/dev\/}

    echo "Displaying information for each removable device:"
    lsblk -d -b -l -o NAME,MODEL ${paths[@]}
}

function get_mount_points()
{
    local drive=$1
    echo $( grep ${drive} /proc/mounts | sort | cut -d ' ' -f 2 )
}

function get_sdcard_layouts()
{
    local names=$( ls ${BAALUE_HOME}/images/*.layout )
    local layouts
    for layout in ${names[@]}; do
	layouts=("${layouts[@]}" "$(basename $layout)")
    done

    echo ${layouts[@]}
}

function proceed_query()
{
    while true; do
	read -p "Proceed? " yn
	case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
	esac
    done
}

function sfdisk_overwrite()
{
    local drive=$1
    local layout="${BAALUE_HOME}/images/${2}"
    menu ""
    sudo sfdisk /dev/${drive} < ${layout}
}

function select_layout()
{
    local layouts=$(get_sdcard_layouts)
    echo $( menu "select layout for sdcard" layouts[@] )
}

function clean_sdcard()
{
    local card=$1
    local keep_partition=$2

    echo "keep_partition: ${keep_partition}"

    if [ $keep_partition -eq 0 ]; then
	echo "sudo dd if=/dev/zero of=/dev/${card} bs=1M count=1"
	sudo dd if=/dev/zero of=/dev/${card} bs=1M count=1
    else
	echo "sudo dd if=/dev/zero of=/dev/${card} bs=1k count=1023 seek=1"
	sudo dd if=/dev/zero of=/dev/${card} bs=1k count=1023 seek=1
    fi
}

function yes_no_question()
{
    local question=$1
    local retval
    while true; do
	read -p "${question} [y/n] " yn
	case $yn in
            [Yy]* )
		echo 1
		break;;
            [Nn]* )
		echo 0
		break;;
            * ) echo "Please answer yes or no.";;
	esac
    done
}

function wait_for_remount()
{
    local drive=$1
    local mounts
    local finished=0

    while [ $finished -eq 0 ]; do
	mounts=$( grep ${drive} /proc/mounts | sort | cut -d ' ' -f 1 | sed s/^.*${drive}// | tr '\n' ' ' )
	finished=$(echo $mounts | grep -c "1 2 3")
    done
}

################################################################
# start of script
################################################################
drives=$(get_removable_drives)
if [ "$drives" == "" ]; then
    echo "error: no removable drive found"
    exit -1
fi

# select the target device
# =========================
print_drive_details $drives
echo ""
drv=$( menu "select device with sdcard" drives[@] )
if [ "$drv" == "" ]; then
    echo "aborting"
    exit -2
fi

# clean the card
# ================
mounts=$( get_mount_points $drv )
if [ "${mounts}" != "" ]; then
    echo "Umounting ${drv} before partitioning"
    sudo umount ${mounts}
fi

keep_partition=$(yes_no_question "Do you want to keep the partition table?")
echo "keep_partition: ${keep_partition}"
clean_sdcard $drv $keep_partition

if [ $keep_partition -eq 0 ]; then
    # select partition layout
    # ========================
    echo "Writing partition table"
    layout=$(select_layout)
    sfdisk_overwrite ${drv} ${layout}
    echo "... finished"
fi
proceed_query

# update partition settings
mounts=$( get_mount_points $drv )
echo "Umounting ${drv} before creating file systems"
sudo umount ${mounts}
sudo mkfs.vfat -F 32 -n KERNEL_BANA /dev/${drv}1
sudo mkfs.ext4 -O ^has_journal -L ROOTFS_BANA /dev/${drv}2
sudo mkfs.ext4 -O ^has_journal -L HOME_BANA /dev/${drv}3
sudo mkswap /dev/${drv}4

echo "Waiting for remount of partitions"
wait_for_remount $drv

cd ${BAALUE_HOME}/bananapi/u-boot/
sudo dd if=u-boot-sunxi-with-spl.bin of=/dev/${drv} bs=1024 seek=8
proceed_query

# check for the mount points
# ===========================
mounts=( $( get_mount_points $drv ) )
kernel_mnt=${mounts[0]}
root_mnt=${mounts[1]}
home_mnt=${mounts[2]}

echo ""
echo "Detected following mount points:"
echo "    kernel: $kernel_mnt"
echo "    root  : $root_mnt"
echo "    home  : $home_mnt"
echo "The contents of these partitions will be overwritten"
proceed_query

cd ${BAALUE_HOME}/bananapi/u-boot/
sudo cp u-boot-sunxi-with-spl.bin boot.cmd boot.scr ${kernel_mnt}/
cd $root_mnt
sudo tar xzpvf ${BAALUE_HOME}/images/rootfs_baalue_bananapi.tgz .
cd $home_mnt
sudo tar xzpvf ${BAALUE_HOME}/images/home_baalue_bananapi.tgz .
cd $kernel_mnt
sudo tar xzpvf ${BAALUE_HOME}/images/kernel_baalue_bananapi.tgz .

echo "Finished!!!"
exit 0
