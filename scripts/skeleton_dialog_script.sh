#!/usr/bin/env bash
################################################################################
#
# Title       :    skeleton_dialog_script.sh  (!!!!! TODO !!!!!)
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
# Date/Beginn :    14.07.2016/14.07.2016
#
# Version     :    V0.01
#
# Milestones  :    V0.01 (jul 2016) -> initial skeleton
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple skeleton      (!!!!! TODO !!!!!)
#
# Some features
#   - ...
#
################################################################################
#

# VERSION-NUMBER
VER='0.01'

# use dialog maybe later zenity
DIALOG=dialog

# if env is sourced
MISSING_ENV='false'

# pid of logterm ($TERM)
PID_LOGTERM=0

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ./skeleton_dialog_script.sh (!!!!! TODO !!!!!)  |"
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
# (!!!!! TODO !!!!!)
_temp="/tmp/skeleton_dialog_script.$$"
_log="/tmp/skeleton_dialog_script.log"


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
	$DIALOG --msgbox "$TERM already running" 6 46
    else
	$TERM -e tail -f ${_log} &
	PID_LOGTERM=$!
    fi
}

menu_one()
{
    echo "menu_one"

    $DIALOG --infobox "menu number one" 3 30
    #my_script.sh >>$_log 2>&1

    normal_exit
}

menu_two()
{
    echo "menu_two"

    $DIALOG --msgbox "menu number two" 5 30
    #my_script.sh >>$_log 2>&1
}

menu_three()
{
    echo "menu_three"
    $DIALOG --textbox ${ARMHF_HOME}/README.md 50 100
}

menu_four()
{
    echo "menu_four"
    echo "KAAAAESSSE" >>$_log 2>&1
}

menu()
{
    # (!!!!! TODO !!!!!)
    $DIALOG  --backtitle "skeleton_dialog_script.sh" \
	     --title "main menu - Version $VER " \
	     --menu "move using [UP] [DOWN] and [Enter] to select" 20 60 10 \
	     1 "menu entry number one"  \
	     2 "menu entry number two"  \
	     3 "menu entry number three"  \
	     4 "menu entry number four"  \
	     5 "start log term ${TERM}" \
             x "Exit" 2>$_temp

    retv=$?
    if [ $retv != 0 ]; then my_exit; fi

    menuitem=`cat $_temp`
    echo "menu=$menuitem"
    case $menuitem in
	1) menu_one ;;
	2) menu_two;;
	3) menu_three;;
	4) menu_four;;
	5) start_logterm;;
        x) normal_exit;;
    esac
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

while true;
do
    menu
done

# should never reached
