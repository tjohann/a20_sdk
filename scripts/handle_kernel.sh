#!/usr/bin/env bash
################################################################################
#
# Title       :    handle_kernel.sh
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
# Date/Beginn :    27.09.2016/23.09.2016
#
# Version     :    V2.00
#
# Milestones  :    V2.00 (sep 2016) -> update version info fo A20_SDK_V2.0.0
#                  V0.02 (sep 2016) -> first working version
#                  V0.01 (sep 2016) -> initial version
#
# Requires    :    dialog, xterm
#
#
################################################################################
# Description
#
#   A simple tool build and install a kernel
#
# Some features
#   - ...
#
################################################################################
#

# VERSION-NUMBER
VER='2.00'

# use dialog
DIALOG=dialog

# if env is sourced
MISSING_ENV='false'

# pid of logterm ($TERM)
PID_LOGTERM=0

# which brand?
BRAND='none'

# which kernel to build?
RT_KERNEL='false'
NORT_KERNEL='false'

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

# --- show help info
show_help()
{
    $DIALOG --textbox ${ARMHF_HOME}/scripts/Documentation/handle_kernel_help.md 50 100
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

# --- select wich kernel to build
select_kernel()
{
    if [ "$RT_KERNEL" = 'true' ]; then
	local def_rt_kernel="on"
    else
	local def_rt_kernel="off"
    fi

    if [ "$NORT_KERNEL" = 'true' ]; then
	local def_nonrt_kernel="on"
    else
	local def_nonrt_kernel="off"
    fi

    dialog --checklist "Select kernel:" 15 60 15 \
           01 "RT-PREEMPT kernel?" ${def_rt_kernel}\
           02 "PREEMPT kernel?" ${def_nonrt_kernel} 2>$_temp
    local result=`cat $_temp`

    if [[ $result == *01* ]]; then
	RT_KERNEL='true'
    else
	RT_KERNEL='false'
    fi

    if [[ $result == *02* ]]; then
	NORT_KERNEL='true'
    else
	NORT_KERNEL='false'
    fi

    local config="
RT-PREEMPT kernel?: ${RT_KERNEL}\n
PREEMPT kernel?: ${NORT_KERNEL}"
    $DIALOG --title " Kernel version selected " --msgbox "Actual kernel\n-------------\n${config}" 10 60
}

# --- download the kernel sources
download_kernel()
{
    start_logterm

    $DIALOG --infobox "Download kernel sources" 6 45

    if [ "$RT_KERNEL" == 'true' ] && [ "$NORT_KERNEL" == 'true' ]; then
 	local kernel_version="-a"
    else
	if [ "$NORT_KERNEL" = 'true' ]; then
	    local kernel_version="-n"
	fi
	if [ "$RT_KERNEL" = 'true' ]; then
	    local kernel_version="-r"
	fi
    fi

    echo "${ARMHF_HOME}/scripts/get_latest_linux_kernel.sh ${kernel_version}" >>$_log 2>&1
    ${ARMHF_HOME}/scripts/get_latest_linux_kernel.sh ${kernel_version}
    if [ $? -ne 0 ] ; then
	$DIALOG --msgbox "ERROR: could not download kernel ... pls check logterm output" 6 45
    else
	$DIALOG --msgbox "Finished download" 6 45
    fi
}

# --- build a kernel
build_kernel()
{
    start_logterm

    $DIALOG --infobox "Build kernel sources" 6 45

    if [ "$RT_KERNEL" == 'true' ] && [ "$NORT_KERNEL" == 'true' ]; then
 	local kernel_version="-a"
    else
	if [ "$NORT_KERNEL" = 'true' ]; then
	    local kernel_version="-n"
	fi
	if [ "$RT_KERNEL" = 'true' ]; then
	    local kernel_version="-r"
	fi
    fi

    echo "${ARMHF_HOME}/scripts/build_kernel.sh ${kernel_version}" >>$_log 2>&1
    ${ARMHF_HOME}/scripts/build_kernel.sh ${kernel_version}
    if [ $? -ne 0 ] ; then
	$DIALOG --msgbox "ERROR: could not build kernel ... pls check logterm output" 6 45
    else
	$DIALOG --msgbox "Finished build" 6 45
    fi
}

# --- install the kernel to $BRAND
install_kernel()
{
    start_logterm

    $DIALOG --infobox "Install kernel sources" 6 45

    if [ "$RT_KERNEL" == 'true' ] && [ "$NORT_KERNEL" == 'true' ]; then
 	local kernel_version="-a"
    else
	if [ "$NORT_KERNEL" = 'true' ]; then
	    local kernel_version="-n"
	fi
	if [ "$RT_KERNEL" = 'true' ]; then
	    local kernel_version="-r"
	fi
    fi

    echo "${ARMHF_HOME}/scripts/install_kernel.sh  ${kernel_version} -b ${BRAND}" >>$_log 2>&1
    ${ARMHF_HOME}/scripts/install_kernel.sh ${kernel_version} -b ${BRAND}
    if [ $? -ne 0 ] ; then
	$DIALOG --msgbox "ERROR: could not install kernel ... pls check logterm output" 6 45
    else
	$DIALOG --msgbox "Finished installation" 6 45
    fi
}

#
# --- main menu
#
menu()
{
    $DIALOG  --title " Main menu ${PROGRAM_NAME} - version $VER " \
	     --menu " Move using [UP] [DOWN] and [Enter] to select an entry" 20 60 20 \
	     1 "Select target device" \
	     2 "Select kernel versions (RT-PREEMPT/PREEMPT)" \
	     3 "Download kernel" \
	     4 "Build kernel" \
	     5 "Install kernel to ${BRAND}" \
	     6 "Show help" \
             x "Exit" 2>$_temp

    local result=$?
    if [ $result != 0 ]; then normal_exit; fi

    local menuitem=`cat $_temp`
    echo "menu=$menuitem"
    case $menuitem in
	1) select_target ;;
	2) select_kernel ;;
	3) download_kernel ;;
	4) build_kernel ;;
	5) install_kernel ;;
	6) show_help;;
        x) normal_exit;;
    esac
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

# sudo handling up-front
echo " "
echo "+------------------------------------------+"
echo "| Download, build and install a linux      |"
echo "| kernel on a sdcard                       |"
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
