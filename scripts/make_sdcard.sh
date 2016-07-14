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
# Date/Beginn :    13.07.2016/10.07.2016
#
# Version     :    V0.02
#
# Milestones  :    V0.02 (jul 2016) -> fist code parts
#                  V0.01 (jul 2016) -> initial skeleton
#
# Requires    :
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
VER='0.02'

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

# use only base image
BASE_IMAGE='false'

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ./make_sdcard.sh                                |"
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
    echo "+-----------------------------------+"
    echo "| You are using version: ${VER}       |"
    echo "+-----------------------------------+"
    cleanup
    exit
}

# ---- Some values for internal use ----
_temp="/tmp/make_sdcard.$$"
_log="/tmp/make_sdcard.log"


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

# --- only a dummy function
dummy_function()
{
    echo "dummy_function"
    echo "dummy_function" >>$_log 2>&1
    $DIALOG --infobox "DUMMY" 3 30
}

# --- use xterm as something like a logterm
start_logterm()
{
    if [ -f /proc/${PID_LOGTERM}/exe ]; then
	$DIALOG --msgbox "$TERM already running" 6 46
    else
	$TERM -e tail -f ${_log} &
	PID_LOGTERM=$!
    fi
}

# --- start partition_sdcard.sh
show_configuration()
{
    local config="
Device node: ${DEVNODE}\n
Target device: ${BRAND}\n
HDD installation?: ${PREP_HDD_INST}\n
Only base image?: ${BASE_IMAGE}"
    $DIALOG --msgbox "Actual configuration\n--------------------\n${config}" 15 60
}

# --- start partition_sdcard.sh
partition_sdcard()
{
    if [[ -b ${DEVNODE} ]]; then
	 $DIALOG --infobox "Start script to partition ${DEVNODE}" 3 30

	 local do_hdd_inst=""
	 local use_base_image=""

	 echo "${ARMHF_HOME}/scripts/partition_sdcard.sh ${do_hdd_inst} ${use_base_image} -b ${BRAND} -d ${DEVNODE} " >>$_log 2>&1
	 ${ARMHF_HOME}/scripts/partition_sdcard.sh  ${do_hdd_inst} ${use_base_image} -b ${BRAND} -d ${DEVNODE} >>$_log 2>&1
	 if [ $? -ne 0 ] ; then
	     $DIALOG --msgbox "ERROR: could not partition ${DEVNODE} ... pls check logterm output" 6 45
	 else
	     $DIALOG --msgbox "Finished partition of ${DEVNODE}" 6 30
	 fi
     else
	 $DIALOG --msgbox "ERROR: ${DEVNODE} is not a block device!" 6 45
     fi
}

# --- start format_sdcard.sh
format_sdcard()
{
     if [[ -b ${DEVNODE} ]]; then
	 $DIALOG --infobox "Start script to format ${DEVNODE}" 3 30

	 local do_hdd_inst=""
	 local use_base_image=""

	 echo "${ARMHF_HOME}/scripts/format_sdcard.sh ${do_hdd_inst} ${use_base_image} -b ${BRAND} -d ${DEVNODE} " >>$_log 2>&1
	 ${ARMHF_HOME}/scripts/format_sdcard.sh ${do_hdd_inst} ${use_base_image} -b ${BRAND} -d ${DEVNODE} >>$_log 2>&1
	 if [ $? -ne 0 ] ; then
	     $DIALOG --msgbox "ERROR: could not format ${DEVNODE} ... pls check logterm output" 6 45
	 else
	     $DIALOG --msgbox "Finished formating of ${DEVNODE}" 6 30
	 fi
     else
	 $DIALOG --msgbox "ERROR: ${DEVNODE} is not a block device!" 6 45
     fi
}

# --- show content of ${ARMHF_HOME}/README.md (something like a help info)
show_help()
{
    $DIALOG --textbox ${ARMHF_HOME}/README.md 50 100
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
    dialog --radiolist "Target device to choose:" 15 60 15 \
           01 "Bananapi-Pro" off\
           02 "Bananapi" on\
           03 "Baalue" off\
           04 "Cubietruck" off\
           05 "Olimex" off 2>$_temp
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
    dialog --checklist "Additional options:" 15 60 15 \
           01 "Prepare HDD installation" off\
           02 "Use minimal images" off 2>$_temp
    local result=`cat $_temp`

    case "$result" in
	*01*)
	    PREP_HDD_INST='true' ;;
	*02*)
	    BASE_IMAGE='true'
    esac

    local config="
HDD installation?: ${PREP_HDD_INST}\n
Only base image?: ${BASE_IMAGE}"
    $DIALOG --title " Addtional options selected " --msgbox "Actual configuration\n--------------------\n${config}" 10 60
}

# --- call everything in line
do_all_in_line()
{
    enter_device_node
    select_target
    select_adds

    # ...
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
		 3 "Addtional options (HDD/small)" \
		 4 "Show actual configuration" \
		 x "Main menu" 2>$_temp

	retv=$?
	if [ $retv != 0 ]; then menu; fi

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
		 3 "Show actual partitions of SD-Card ${DEVNODE}" \
		 x "Main menu" 2>$_temp

	retv=$?
	if [ $retv != 0 ]; then menu; fi

	local menuitem=`cat $_temp`
	echo "menu=$menuitem"
	case $menuitem in
	    1) partition_sdcard;;
	    2) format_sdcard;;
	    3) dummy_function;;
	    x) menu;;
	esac
    done
}

#
# --- main menu
#
menu()
{
    $DIALOG  --title " Main menu make_sdcard.sh - version $VER " \
	     --menu " Move using [UP] [DOWN] and [Enter] to select an entry" 20 60 20 \
	     1 "Configuration menu" \
	     2 "SD-Card menu" \
	     3 "Download SD-Card images for target device ${BRAND}" \
	     4 "Write images of ${BRAND} to ${DEVNODE}" \
	     5 "Write bootloader to ${DEVNODE}" \
	     6 "Do all steps in line" \
	     7 "Show actual configuration" \
	     8 "Start logging via ${TERM} console output" \
	     9 "Show ${ARMHF_HOME}/README.md" \
             x "Exit" 2>$_temp

    retv=$?
    if [ $retv != 0 ]; then normal_exit; fi

    local menuitem=`cat $_temp`
    echo "menu=$menuitem"
    case $menuitem in
	1) menu_config ;;
	2) menu_sdcard;;
	3) dummy_function;;
	4) dummy_function;;
	5) dummy_function;;
	6) do_all_in_line;;
	7) dummy_function;;
	8) start_logterm;;
	9) show_help;;
        x) normal_exit;;
    esac
}


# http://subsignal.org/doc/AliensBashTutorial.html
# http://www.cc-c.de/german/linux/linux-dialog.php
# http://www.linuxjournal.com/article/2807?page=0,2
# http://www.linuxintro.org/wiki/BaBE_-_Bash_By_Examples
# http://mywiki.wooledge.org/BashFAQ
# http://superuser.com/questions/829921/how-to-get-status-code-of-program-piped-to-linux-dialog-command


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

while true;
do
    menu
done

# should never reached
