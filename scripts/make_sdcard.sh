#!/usr/bin/env bash
################################################################################
#
# Title       :    make_sdcard.sh
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
# Date/Beginn :    27.09.2016/10.07.2016
#
# Version     :    V2.00
#
# Milestones  :    V2.00 (sep 2016) -> update version info fo A20_SDK_V2.0.0
#                  V1.02 (aug 2016) -> a lot of fixes around hdd-boot-sdcard
#                  V1.01 (aug 2016) -> add menuentry to create hdd-boot-sdcard
#                  V1.00 (aug 2016) -> version bump
#                  V0.11 (aug 2016) -> some minor fixes
#                                      remove menu entry to show partitiontable
#                  V0.10 (aug 2016) -> be aware of HDD installation for
#                                      brand_image, write_image and
#                                      write_bootloader
#                  V0.09 (aug 2016) -> some minor approvements around _log/_temp
#                                      add PROGRAM_NAME and use it
#                  V0.08 (jul 2016) -> add info dialog about logging
#                                      fix a lot of minor bugs
#                  V0.07 (jul 2016) -> change help.md location
#                  V0.06 (jul 2016) -> add mount/umount script
#                                      some more minor improvements
#                  V0.05 (jul 2016) -> version number fix
#                  V0.04 (jul 2016) -> add help menu-entry
#                  V0.03 (jul 2016) -> add code to handle sd-card
#                                      fix a lot of bugs and minor problems
#                                      add code to download images
#                                      add code to untar images to sd-card
#                                      add code to brand a sd-card
#                                      add code to write bootloader
#                  V0.02 (jul 2016) -> fist code parts
#                  V0.01 (jul 2016) -> initial skeleton
#
# Requires    :    dialog, xterm
#
#
################################################################################
# Description
#
#   A simple tool for user interaction of sdcard generation
#
# Some features
#   - ...
#
################################################################################
#

# VERSION-NUMBER
VER='2.00'

# use dialog maybe later zenity
DIALOG=dialog

# if env is sourced
MISSING_ENV='false'

# pid of logterm ($TERM)
PID_LOGTERM=0

# which brand?
BRAND='none'

# which devnode?
DEVNODE='none'

# HDD installation?
PREP_HDD_INST='false'

# HDD-boot only sd-card?
HDD_BOOT_SDCARD='false'

# use only base image
BASE_IMAGE='false'

# program name
PROGRAM_NAME=${0##*/}

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
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

# my exit method after an error
my_exit()
{
    echo "+-----------------------------------+"
    echo "|          Cheers $USER            |"
    echo "+-----------------------------------+"
    cleanup
    # http://tldp.org/LDP/abs/html/exitcodes.html
    exit 3
}

# normal leave
normal_exit()
{
    # kill log_term only if no error occured
    killall -u ${USER} -15 tail 2>$_log

    echo "+-----------------------------------+"
    echo "|          Cheers $USER            |"
    echo "+-----------------------------------+"
    cleanup
    exit
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
# ***                      The functions for main_menu                       ***
# ******************************************************************************

# --- use xterm as something like a logterm
start_logterm()
{
    if [ -f /proc/${PID_LOGTERM}/exe ]; then
	echo "$TERM already running -> do nothing" >>$_log 2>&1
    else
	if [ -s $DISPLAY ]; then
	    $DIALOG --msgbox "To see logging output use tail on another tty:

\"tail -n 50 -f ${_log}\"" 10 60
	else
	    $TERM -e tail -f ${_log} &
	    if [ $? -ne 0 ] ; then
		$DIALOG --msgbox "ERROR: could not use $TERM for logging -> pls use xterm/mrxvt" 6 45
	    else
		PID_LOGTERM=$!
		echo "Using $TERM for logging" >>$_log 2>&1
	    fi
	fi
    fi

    echo "$!" >>$_log 2>&1
}

# --- start partition_sdcard.sh
show_configuration()
{
    local config="
Device node: ${DEVNODE}\n
Target device: ${BRAND}\n
HDD installation?: ${PREP_HDD_INST}\n
Only base image?: ${BASE_IMAGE}\n
Only HDD-boot-only image?: ${HDD_BOOT_SDCARD}"
    $DIALOG --msgbox "Actual configuration\n--------------------\n${config}" 15 60
}

# --- start partition_sdcard.sh
partition_sdcard()
{
    if [[ ! -b ${DEVNODE} ]]; then
	$DIALOG --msgbox "ERROR: ${DEVNODE} is not a block device!" 6 45
	return
    fi

    if [ "$BRAND" = 'none' ]; then
	$DIALOG --msgbox "ERROR: ${BRAND} is not a valid target device!" 6 45
	return
    fi

    if [ "$BASE_IMAGE" = 'true' ]; then
	local use_base_image="-m"
    fi

    if [ "$HDD_BOOT_SDCARD" = 'true' ]; then
	local create_hdd_boot_image="-e"
    fi

    if [ "$PREP_HDD_INST" = 'true' ]; then
	local do_hdd_inst="-s"
    fi

    start_logterm

    $DIALOG --infobox "Start script to partition ${DEVNODE}" 6 45

    echo "${ARMHF_HOME}/scripts/partition_sdcard.sh ${do_hdd_inst} ${use_base_image} ${create_hdd_boot_image} -b ${BRAND} -d ${DEVNODE} " >>$_log 2>&1
    ${ARMHF_HOME}/scripts/partition_sdcard.sh  ${do_hdd_inst} ${use_base_image} ${create_hdd_boot_image} -b ${BRAND} -d ${DEVNODE} >>$_log 2>&1
    if [ $? -ne 0 ] ; then
	$DIALOG --msgbox "ERROR: could not partition ${DEVNODE} ... pls check logterm output" 6 45
    else
	$DIALOG --msgbox "Finished partition of ${DEVNODE}" 6 45
    fi
}

# --- start format_sdcard.sh
format_sdcard()
{
    if [[ ! -b ${DEVNODE} ]]; then
	$DIALOG --msgbox "ERROR: ${DEVNODE} is not a block device!" 6 45
	return
    fi

    if [ "$BRAND" = 'none' ]; then
	$DIALOG --msgbox "ERROR: ${BRAND} is not a valid target device!" 6 45
	return
    fi

    if [ "$HDD_BOOT_SDCARD" = 'true' ]; then
	local create_hdd_boot_image="-e"
    fi

    if [ "$PREP_HDD_INST" = 'true' ]; then
	local do_hdd_inst="-s"
    fi

    start_logterm

    $DIALOG --infobox "Start script to format ${DEVNODE}" 6 45

    echo "${ARMHF_HOME}/scripts/format_sdcard.sh ${do_hdd_inst}  ${create_hdd_boot_image}  -b ${BRAND} -d ${DEVNODE} " >>$_log 2>&1
    ${ARMHF_HOME}/scripts/format_sdcard.sh ${do_hdd_inst}  ${create_hdd_boot_image} -b ${BRAND} -d ${DEVNODE} >>$_log 2>&1
    if [ $? -ne 0 ] ; then
	$DIALOG --msgbox "ERROR: could not format ${DEVNODE} ... pls check logterm output" 6 45
    else
	$DIALOG --msgbox "Finished formating of ${DEVNODE}" 6 45
    fi
}

# --- download the images
download_images()
{
    if [ "$BRAND" = 'none' ]; then
	$DIALOG --msgbox "ERROR: ${BRAND} is not a valid target device!" 6 45
	return
    fi

    if [ "$BASE_IMAGE" = 'true' ]; then
	local use_base_image="-m"
    fi

    if [ "$PREP_HDD_INST" = 'true' ]; then
	local do_hdd_inst="-s"
    fi

    if [ "$HDD_BOOT_SDCARD" = 'true' ]; then
	local create_hdd_boot_image="-e"
    fi

    start_logterm

    $DIALOG --infobox "Download images for ${BRAND}" 6 45

    echo "${ARMHF_HOME}/scripts/get_image_tarballs.sh ${do_hdd_inst} ${use_base_image} ${create_hdd_boot_image} -b ${BRAND}" >>$_log 2>&1
    ${ARMHF_HOME}/scripts/get_image_tarballs.sh ${do_hdd_inst} ${use_base_image} ${create_hdd_boot_image} -b ${BRAND} >>$_log 2>&1
    if [ $? -ne 0 ] ; then
	$DIALOG --msgbox "ERROR: could not download images ... pls check logterm output" 6 45
    else
	$DIALOG --msgbox "Finished download images for ${BRAND}" 6 45
    fi
}

# --- write images to sd-card
write_images()
{
    if [ "$BRAND" = 'none' ]; then
	$DIALOG --msgbox "ERROR: ${BRAND} is not a valid target device!" 6 45
	return
    fi

    if [ "$BASE_IMAGE" = 'true' ]; then
	local use_base_image="-m"
    fi

    if [ "$PREP_HDD_INST" = 'true' ]; then
	local do_hdd_inst="-s"
    fi

    if [ "$HDD_BOOT_SDCARD" = 'true' ]; then
	local create_hdd_boot_image="-e"
    fi

    start_logterm

    $DIALOG --infobox "Write images for ${BRAND}" 6 45

    echo "${ARMHF_HOME}/scripts/untar_images_to_sdcard.sh ${do_hdd_inst} ${use_base_image} ${create_hdd_boot_image} -b ${BRAND}" >>$_log 2>&1
    ${ARMHF_HOME}/scripts/untar_images_to_sdcard.sh ${do_hdd_inst} ${use_base_image} ${create_hdd_boot_image} -b ${BRAND} >>$_log 2>&1
    if [ $? -ne 0 ] ; then
	$DIALOG --msgbox "ERROR: could not write images for ${BRAND}... pls check logterm output" 6 45
    else
	$DIALOG --msgbox "Finished write of images for ${BRAND} to ${DEVNODE}" 6 45
    fi
}

# --- brand a sd-card
brand_sd-card()
{
    if [ "$BRAND" = 'none' ]; then
	$DIALOG --msgbox "ERROR: ${BRAND} is not a valid target device!" 6 45
	return
    fi

    if [ "$PREP_HDD_INST" = 'true' ]; then
	local do_hdd_inst="-s"
    fi

    start_logterm

    $DIALOG --infobox "Brand images for ${BRAND}" 6 45

    echo "${ARMHF_HOME}/scripts/brand_images.sh ${do_hdd_inst} -b ${BRAND}" >>$_log 2>&1
    ${ARMHF_HOME}/scripts/brand_images.sh ${do_hdd_inst} -b ${BRAND} >>$_log 2>&1
    if [ $? -ne 0 ] ; then
	$DIALOG --msgbox "ERROR: could not brand images for ${BRAND}... pls check logterm output" 6 45
    else
	$DIALOG --msgbox "Finished branding of images for ${BRAND} to ${DEVNODE}" 6 45
    fi
}

# --- write u-boot to sd-card
write_bootloader()
{
    if [[ ! -b ${DEVNODE} ]]; then
	$DIALOG --msgbox "ERROR: ${DEVNODE} is not a block device!" 6 45
	return
    fi

    if [ "$BRAND" = 'none' ]; then
	$DIALOG --msgbox "ERROR: ${BRAND} is not a valid target device!" 6 45
	return
    fi

    if [ "$PREP_HDD_INST" = 'true' ]; then
	local do_hdd_inst="-s"
    fi

    if [ "$HDD_BOOT_SDCARD" = 'true' ]; then
	local create_hdd_boot_image="-e"
    fi

    start_logterm

    $DIALOG --infobox "Start script to write bootloader to ${DEVNODE}" 6 45

    echo "${ARMHF_HOME}/scripts/write_bootloader.sh ${do_hdd_inst}  ${create_hdd_boot_image} -b ${BRAND} -d ${DEVNODE} " >>$_log 2>&1
    ${ARMHF_HOME}/scripts/write_bootloader.sh ${do_hdd_inst}  ${create_hdd_boot_image} -b ${BRAND} -d ${DEVNODE} >>$_log 2>&1
    if [ $? -ne 0 ] ; then
	$DIALOG --msgbox "ERROR: could not write bootloader to ${DEVNODE} ... pls check logterm output" 6 45
    else
	$DIALOG --msgbox "Finished writing bootloader to ${DEVNODE}" 6 45
    fi
}

# --- mount partitions
mount_partitions()
{
    if [ "$BRAND" = 'none' ]; then
	$DIALOG --msgbox "ERROR: ${BRAND} is not a valid target device!" 6 45
	return
    fi

    if [ "$HDD_BOOT_SDCARD" = 'true' ]; then
	local create_hdd_boot_image="-e"
    fi

    if [ "$PREP_HDD_INST" = 'true' ]; then
	local do_hdd_inst="-s"
    fi

    start_logterm

    $DIALOG --infobox "Mount partions for ${BRAND}" 6 45

    echo "${ARMHF_HOME}/scripts/mount_partitions.sh ${do_hdd_inst} ${create_hdd_boot_image} -b ${BRAND} -m" >>$_log 2>&1
    ${ARMHF_HOME}/scripts/mount_partitions.sh ${do_hdd_inst} ${create_hdd_boot_image} -b ${BRAND} -m >>$_log 2>&1
    if [ $? -ne 0 ] ; then
	$DIALOG --msgbox "ERROR: could not mount partitions for ${BRAND}... pls check logterm output" 6 45
    else
	$DIALOG --msgbox "Finished mount of partitions for ${BRAND}" 6 45
    fi
}

# --- umount partitions
umount_partitions()
{
    if [ "$BRAND" = 'none' ]; then
	$DIALOG --msgbox "ERROR: ${BRAND} is not a valid target device!" 6 45
	return
    fi

    if [ "$HDD_BOOT_SDCARD" = 'true' ]; then
	local create_hdd_boot_image="-e"
    fi

    if [ "$PREP_HDD_INST" = 'true' ]; then
	local do_hdd_inst="-s"
    fi

    start_logterm

    $DIALOG --infobox "Un-mount partions for ${BRAND}" 6 45

    echo "${ARMHF_HOME}/scripts/mount_partitions.sh ${do_hdd_inst} ${create_hdd_boot_image} -b ${BRAND} -u" >>$_log 2>&1
    ${ARMHF_HOME}/scripts/mount_partitions.sh ${do_hdd_inst} ${create_hdd_boot_image} -b ${BRAND} -u >>$_log 2>&1
    if [ $? -ne 0 ] ; then
	$DIALOG --msgbox "ERROR: could not un-mount partitions for ${BRAND}... pls check logterm output" 6 45
    else
	$DIALOG --msgbox "Finished un-mount of partitions for ${BRAND}" 6 45
    fi
}

# --- show content of ${ARMHF_HOME}/README.md (something like a help info)
show_sdk_readme()
{
    $DIALOG --textbox ${ARMHF_HOME}/README.md 50 100
}

# --- show help info
show_help()
{
    $DIALOG --textbox ${ARMHF_HOME}/scripts/Documentation/make_sdcard_help.md 50 100
}

# --- enter a device node
enter_device_node()
{
    dialog --inputbox "Enter a valid device node (/dev/sdd or /dev/mmcblk0p): " 8 60 2>$_temp

    DEVNODE=`cat $_temp`
    dialog --title " Entered device node " --msgbox "Will use \"${DEVNODE}\" for all following actions" 5 60
}

# --- select a supported target device
select_target()
{
    local def_bananapi_pro="off"
    local def_bananapi="off"
    local def_baalue="off"
    local def_cubietruck="off"
    local def_olimex="off"

    case "$BRAND" in
	*bananapi-pro*)
	    def_bananapi_pro="on" ;;
	*bananapi*)
	    def_bananapi="on" ;;
	*baalue*)
	    def_baalue="on" ;;
	*cubietruck*)
	    def_cubietruck="on" ;;
	*olimex*)
	    def_olimex="on" ;;
    esac

    dialog --radiolist "Target device to choose:" 15 60 15 \
           01 "Bananapi-Pro" ${def_bananapi_pro} \
           02 "Bananapi" ${def_bananapi} \
           03 "Baalue" ${def_baalue} \
           04 "Cubietruck" ${def_cubietruck} \
           05 "Olimex" ${def_olimex} 2>$_temp
    local result=`cat $_temp`

    case "$result" in
	*01*)
	    BRAND="bananapi-pro" ;;
	*02*)
	    BRAND="bananapi" ;;
	*03*)
	    BRAND="baalue" ;;
	*04*)
	    BRAND="cubietruck" ;;
	*05*)
	    BRAND="olimex" ;;
    esac

    dialog --title " Target device selected " --msgbox "Will use \"${BRAND}\" for all following actions" 5 60
}

# --- select format options
select_adds()
{
    if [ "$PREP_HDD_INST" = 'true' ]; then
	local def_prep_hdd_inst="on"
    else
	local def_prep_hdd_inst="off"
    fi

    if [ "$BASE_IMAGE" = 'true' ]; then
	local def_base_image="on"
    else
	local def_base_image="off"
    fi

    if [ "$HDD_BOOT_SDCARD" = 'true' ]; then
	local def_boot_sdcard="on"
    else
	local def_boot_sdcard="off"
    fi

    dialog --checklist "Additional options:" 15 60 15 \
           01 "Prepare HDD installation" ${def_prep_hdd_inst}\
           02 "Use minimal images" ${def_base_image} \
	   03 "HDD-boot-only images" ${def_boot_sdcard} 2>$_temp
    local result=`cat $_temp`

    if [[ $result == *01* ]]; then
	PREP_HDD_INST='true'
    else
	PREP_HDD_INST='false'
    fi

    if [[ $result == *02* ]]; then
	BASE_IMAGE='true'
    else
	BASE_IMAGE='false'
    fi

    if [[ $result == *03* ]]; then
	HDD_BOOT_SDCARD='true'
    else
	HDD_BOOT_SDCARD='false'
    fi

    local config="
HDD installation?: ${PREP_HDD_INST}\n
Only base image?: ${BASE_IMAGE}\n
Only HDD-boot-only image?: ${HDD_BOOT_SDCARD}"
    $DIALOG --title " Addtional options selected " --msgbox "Actual configuration\n--------------------\n${config}" 10 60
}

# --- call everything in line
do_all_in_line()
{
    # user input for configuration
    enter_device_node
    select_target
    select_adds
    show_configuration

    dialog --title "Do all steps in line - step 1" \
	   --yesno "Do you want to continue?" 6 45
    local result=$?
    case $result in
	0) echo "continue" >>$_log 2>&1;;
	1) menu ;;
	255) menu;;
    esac

    # download parts
    download_images

    dialog --title "Do all steps in line - step 2" \
	   --yesno "Do you want to continue?" 6 45
    local result=$?
    case $result in
	0) echo "continue" >>$_log 2>&1;;
	1) menu ;;
	255) menu;;
    esac

    # partition sd-card
    partition_sdcard

    dialog --title "Do all steps in line - step 3" \
	   --yesno "Do you want to continue?" 6 45
    local result=$?
    case $result in
	0) echo "continue" >>$_log 2>&1;;
	1) menu ;;
	255) menu;;
    esac

    # prepare sd-card
    write_images
    brand_sd-card
    write_bootloader

    $DIALOG --msgbox "Finished make of sd-card for ${BRAND}" 6 45
}

# --- create a hdd boot sd-card
create_hdd_boot_sd-card()
{
    # download parts
    download_images

    dialog --title "Create a hdd boot sd-card - step 1" \
	   --yesno "Do you want to continue?" 6 45
    local result=$?
    case $result in
	0) echo "continue" >>$_log 2>&1;;
	1) menu ;;
	255) menu;;
    esac

    # partition sd-card
    partition_sdcard

    dialog --title "Create a hdd boot sd-card - step 2" \
	   --yesno "Do you want to continue?" 6 45
    local result=$?
    case $result in
	0) echo "continue" >>$_log 2>&1;;
	1) menu ;;
	255) menu;;
    esac

    # prepare sd-card
    write_images
    write_bootloader

    $DIALOG --msgbox "Finished make of hdd-boot-sdcard for ${BRAND}" 6 45
}

#
# --- special menu to configure needed arguments
#
menu_config()
{
    while true
    do
	$DIALOG  --title " Configuration menu " \
		 --menu " Move using [UP] [DOWN] and [Enter] to select an entry" 20 60 20 \
		 1 "Enter device node (/dev/sdx)" \
		 2 "Select target device (Bananapi/...)" \
		 3 "Addtional options (HDD/small...)" \
		 4 "Show actual configuration" \
		 x "Main menu" 2>$_temp

	local result=$?
	if [ $result != 0 ]; then menu; fi

	local menuitem=`cat $_temp`
	echo "menu=$menuitem"
	case $menuitem in
	    1) enter_device_node;;
	    2) select_target;;
	    3) select_adds;;
	    4) show_configuration;;
	    x) menu;;
	esac
    done
}

#
# --- special menu to create a ready to use SD-Card
#
menu_sdcard()
{
    while true
    do
	$DIALOG  --title " SD-Card handling menu " \
		 --menu " Move using [UP] [DOWN] and [Enter] to select an entry" 20 60 20 \
		 1 "Partition (and format) SD-Card ${DEVNODE}" \
		 2 "Format already partitioned SD-Card ${DEVNODE}" \
		 3 "Write images to ${DEVNODE}" \
		 4 "Write bootloader to ${DEVNODE}" \
		 5 "Brand SD-Card" \
		 6 "Show actual configuration" \
		 7 "Mount partions for ${BRAND}" \
		 8 "Un-mount partions for ${BRAND}" \
		 x "Main menu" 2>$_temp

	local result=$?
	if [ $result != 0 ]; then menu; fi

	local menuitem=`cat $_temp`
	echo "menu=$menuitem"
	case $menuitem in
	    1) partition_sdcard;;
	    2) format_sdcard;;
	    3) write_images;;
	    4) write_bootloader;;
	    5) brand_sd-card;;
	    6) show_configuration;;
	    7) mount_partitions;;
	    8) umount_partitions;;
	    x) menu;;
	esac
    done
}

#
# --- main menu
#
menu()
{
    $DIALOG  --title " Main menu ${PROGRAM_NAME} - version $VER " \
	     --menu " Move using [UP] [DOWN] and [Enter] to select an entry" 20 60 20 \
	     1 "Configuration menu" \
	     2 "Download images for target device ${BRAND}" \
	     3 "SD-Card menu" \
	     4 "Do all steps in line" \
	     5 "Create a HDD-Boot-SD-Card" \
	     6 "Show actual configuration" \
	     7 "Start logging via ${TERM} console output" \
	     8 "Show ${ARMHF_HOME}/README.md" \
	     9 "Show help" \
             x "Exit" 2>$_temp

    local result=$?
    if [ $result != 0 ]; then normal_exit; fi

    local menuitem=`cat $_temp`
    echo "menu=$menuitem"
    case $menuitem in
	1) menu_config ;;
	2) download_images;;
	3) menu_sdcard;;
	4) do_all_in_line;;
	5) create_hdd_boot_sd-card;;
	6) show_configuration;;
	7) start_logterm;;
	8) show_sdk_readme;;
	9) show_help;;
        x) normal_exit;;
    esac
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

# sudo handling up-front
echo " "
echo "+------------------------------------------+"
echo "| Make a ready-to-use sdcard for your      |"
echo "| target device.                           |"
echo "| --> need sudo for some parts             |"
echo "+------------------------------------------+"
echo " "

sudo -v
# keep-alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

if [ -s $DISPLAY ]; then
    $DIALOG --msgbox "To see logging output use tail on another tty:

\"tail -n 50 -f ${_log}\"" 10 60
fi

while true;
do
    menu
done

# should never reached
