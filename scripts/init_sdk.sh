#!/usr/bin/env bash
################################################################################
#
# Title       :    init_sdk.sh
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
# Date/Beginn :    07.07.2016/25.01.2016
#
# Version     :    V1.01
#
# Milestones  :    V1.01 (jul 2016) -> some minor improvements
#                  V1.00 (jul 2016) -> some minor improvements
#                  V0.08 (jul 2016) -> some minor improvements
#                  V0.07 (may 2016) -> add argument to init home and opt
#                  V0.06 (apr 2016) -> use rsync for all links
#                                      some smaller fixes
#                  V0.05 (apr 2016) -> some cleanups
#                                      add links to documentation
#                  V0.04 (apr 2016) -> fix wrong date
#                                      fix user handling for rsync
#                  V0.03 (apr 2016) -> add srcdir
#                  V0.02 (feb 2016) -> init working-dir
#                  V0.01 (jan 2016) -> first functional version
#
# Requires    :
#
#
################################################################################
# Description
#
#   A simple tool to init the sdk
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
VER='1.01'

# if env is sourced
MISSING_ENV='false'

# init only user home dir
INIT_USER_HOME='false'
INIT_OPT='false'

# my usage method
my_usage()
{
    echo " "
    echo "+--------------------------------------------------------+"
    echo "| Usage: ./init_sdk.sh                                   |"
    echo "|        [-u] -> init only $HOME/src/a20_sdk (srcdir)    |"
    echo "|        [-o] -> init only /opt/a20_sdk (workdir)        |"
    echo "|        [-a] -> init both                               |"
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
    echo "+-----------------------------------+"
    echo "|          Cheers $USER            |"
    echo "+-----------------------------------+"
    cleanup
    exit 2
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
_temp="/tmp/init_sdk.$$"
_log="/tmp/init_sdk.log"


# check the args
while getopts 'hvuoa' opts 2>$_log
do
    case $opts in
        u) INIT_USER_HOME='true' ;;
        o) INIT_OPT='true' ;;
	a) INIT_OPT='true'
	   INIT_USER_HOME='true'
	   ;;
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

add_documentations_links_opt()
{
    # bananapi related docs
    if [ -d ${ARMHF_BIN_HOME}/Documentation/bananapi ]; then
	cd ${ARMHF_BIN_HOME}/Documentation/bananapi
	rsync -av --delete ${ARMHF_HOME}/bananapi/Documentation/. .
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not rsync ${ARMHF_HOME}/bananapi/Documentation/."
	    my_exit
	fi
    else
	echo "ERROR: no dir ${ARMHF_BIN_HOME}/Documentation/bananapi"
    fi

    # bananapi-pro related docs
    if [ -d ${ARMHF_BIN_HOME}/Documentation/bananapi-pro ]; then
	cd ${ARMHF_BIN_HOME}/Documentation/bananapi-pro
	rsync -av --delete ${ARMHF_HOME}/bananapi-pro/Documentation/. .
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not rsync ${ARMHF_HOME}/bananapi-pro/Documentation/."
	    my_exit
	fi
    else
	echo "ERROR: no dir ${ARMHF_BIN_HOME}/Documentation/bananapi-pro"
    fi

    # cubietruck related docs
    if [ -d ${ARMHF_BIN_HOME}/Documentation/cubietruck ]; then
	cd ${ARMHF_BIN_HOME}/Documentation/cubietruck
	rsync -av --delete ${ARMHF_HOME}/cubietruck/Documentation/. .
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not rsync ${ARMHF_HOME}/cubietruck/Documentation/."
	    my_exit
	fi
    else
	echo "ERROR: no dir ${ARMHF_BIN_HOME}/Documentation/cubietruck"
    fi

    # olimex related docs
    if [ -d ${ARMHF_BIN_HOME}/Documentation/olimex ]; then
	cd ${ARMHF_BIN_HOME}/Documentation/olimex
	rsync -av --delete ${ARMHF_HOME}/olimex/Documentation/. .
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not rsync ${ARMHF_HOME}/olimex/Documentation/."
	    my_exit
	fi
    else
	echo "ERROR: no dir ${ARMHF_BIN_HOME}/Documentation/olimex"
    fi
}

add_documentations_links_home()
{
    # bananapi related docs
    if [ -d ${ARMHF_SRC_HOME}/Documentation/bananapi ]; then
	cd ${ARMHF_SRC_HOME}/Documentation/bananapi
	rsync -av --delete ${ARMHF_HOME}/bananapi/Documentation/. .
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not rsync ${ARMHF_HOME}/bananapi/Documentation/."
	    my_exit
	fi
    else
	echo "ERROR: no dir ${ARMHF_SRC_HOME}/Documentation/bananapi"
    fi

    # bananapi-pro related docs
    if [ -d ${ARMHF_SRC_HOME}/Documentation/bananapi-pro ]; then
	cd ${ARMHF_SRC_HOME}/Documentation/bananapi-pro
	rsync -av --delete ${ARMHF_HOME}/bananapi-pro/Documentation/. .
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not rsync ${ARMHF_HOME}/bananapi-pro/Documentation/."
	    my_exit
	fi
    else
	echo "ERROR: no dir ${ARMHF_SRC_HOME}/Documentation/bananapi-pro"
    fi

    # cubietruck related docs
    if [ -d ${ARMHF_SRC_HOME}/Documentation/cubietruck ]; then
	cd ${ARMHF_SRC_HOME}/Documentation/cubietruck
	rsync -av --delete ${ARMHF_HOME}/cubietruck/Documentation/. .
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not rsync ${ARMHF_HOME}/cubietruck/Documentation/."
	    my_exit
	fi
    else
	echo "ERROR: no dir ${ARMHF_SRC_HOME}/Documentation/cubietruck"
    fi

    # olimex related docs
    if [ -d ${ARMHF_SRC_HOME}/Documentation/olimex ]; then
	cd ${ARMHF_SRC_HOME}/Documentation/olimex
	rsync -av --delete ${ARMHF_HOME}/olimex/Documentation/. .
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not rsync ${ARMHF_HOME}/bananapi/Documentation/."
	    my_exit
	fi
    else
	echo "ERROR: no dir ${ARMHF_SRC_HOME}/Documentation/olimex"
    fi
}


# ******************************************************************************
# ***                         Main Loop                                      ***
# ******************************************************************************

echo " "
echo "+----------------------------------------+"
echo "|             init the sdk               |"
echo "+----------------------------------------+"
echo " "

if [ "$INIT_OPT" = 'true' ]; then
    if [ -d $ARMHF_BIN_HOME ]; then
	echo "$ARMHF_BIN_HOME already available"
    else
	echo "Create $ARMHF_BIN_HOME -> need sudo rights! "
	sudo mkdir -p $ARMHF_BIN_HOME
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not mkdir -p $ARMHF_BIN_HOME"
	    my_exit
	fi
	sudo chown $USER:users $ARMHF_BIN_HOME
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not chown $USER:users $ARMHF_BIN_HOME"
	    my_exit
	fi
	sudo chmod 775 $ARMHF_BIN_HOME
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not chmod 775 $ARMHF_BIN_HOME"
	    my_exit
	fi
    fi

    if [ -d $ARMHF_BIN_HOME ]; then
	echo "Rsync content of ${ARMHF_HOME}/a20_sdk/ to $ARMHF_BIN_HOME"
	cd $ARMHF_BIN_HOME
	rsync -av --delete ${ARMHF_HOME}/a20_sdk/. .
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could notrsync -av --delete ${ARMHF_HOME}/a20_sdk/."
	    my_exit
	fi
    else
	echo "$ARMHF_BIN_HOME does not exist"
    fi

    add_documentations_links_opt

    echo "need sudo rights to chown ${USER}:users ${ARMHF_BIN_HOME}"
    sudo chown $USER:users $ARMHF_BIN_HOME
    if [ $? -ne 0 ] ; then
	echo "ERROR -> could not chown $USER:users $ARMHF_BIN_HOME"
	my_exit
    fi
fi

if [ "$INIT_USER_HOME" = 'true' ]; then
    if [ -d $ARMHF_SRC_HOME ]; then
	echo "$ARMHF_SRC_HOME already available"
    else
	echo "Create $ARMHF_SRC_HOME"
	mkdir -p $ARMHF_SRC_HOME
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not mkdir -p $ARMHF_SRC_HOME"
	    my_exit
	fi
    fi

    if [ -d $ARMHF_SRC_HOME ]; then
	cd $ARMHF_SRC_HOME
	echo "Rsync content of ${ARMHF_HOME}/a20_sdk_src/ to $ARMHF_SRC_HOME"
	rsync -av --delete ${ARMHF_HOME}/a20_sdk_src/. .
	if [ $? -ne 0 ] ; then
	    echo "ERROR -> could not rsync -av --delete ${ARMHF_HOME}/a20_sdk_src/."
	    my_exit
	fi
    else
	echo "$ARMHF_SRC_HOME does not exist"
    fi

    add_documentations_links_home
fi

cleanup
echo " "
echo "+----------------------------------------+"
echo "|            Cheers $USER"
echo "+----------------------------------------+"
echo " "
