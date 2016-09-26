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
# Date/Beginn :    23.09.2016/23.09.2016
#
# Version     :    V0.01
#
# Milestones  :    V0.01 (sept 2016) -> initial version
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
VER='0.01'

# use dialog
DIALOG=dialog

# if env is sourced
MISSING_ENV='false'

# pid of logterm ($TERM)
PID_LOGTERM=0

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


# --- show content of ${ARMHF_HOME}/README.md (something like a help info)
show_sdk_readme()
{
    $DIALOG --textbox ${ARMHF_HOME}/README.md 50 100
}

# --- show help info
show_help()
{
    $DIALOG --textbox ${ARMHF_HOME}/scripts/Documentation/handle_kernel_help.md 50 100
}

#
# --- main menu
#
menu()
{
    $DIALOG  --title " Main menu ${PROGRAM_NAME} - version $VER " \
	     --menu " Move using [UP] [DOWN] and [Enter] to select an entry" 20 60 20 \
	     1 "Configuration menu" \
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
echo "| Download, build and install a linux      |"
echo "| kernel on a sdcard                       |"
echo "+------------------------------------------+"
echo " "

if [ -s $DISPLAY ]; then
    $DIALOG --msgbox "To see logging output use tail on another tty:

\"tail -n 50 -f ${_log}\"" 10 60
fi

while true;
do
    menu
done

# should never reached
