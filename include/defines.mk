################################################################################
#
# Title       :    defines.mk
#
# (c) 2015-2016, thorsten.johannvorderbrueggen@t-online.de
#
################################################################################
#
# Description:
#   Common defines for all code used within this sdk.
#
# Usage:
#   - source armhf_env
#   - add this to the makefile
#   SNIP
#   include ${ARMHF_HOME}/include/defines.mk
#   SNIP
#
################################################################################
#

# ---- host ----
CC = gcc
AR = ar
LD = ld

CFLAGS = -I${ARMHF_SRC_HOME}/include -g -Wall -Wextra -std=gnu11
LDLIBS = -L${ARMHF_SRC_HOME}/lib -lpthread -lrt

# ---- target ----
ifeq (${MY_HOST_ARCH},x86_64)
	CC_TARGET = arm-none-linux-gnueabihf-gcc
	AR_TARGET = arm-none-linux-gnueabihf-ar
	LD_TARGET = arm-none-linux-gnueabihf-ld
else
	CC_TARGET = gcc
	AR_TARGET = ar
	LD_TARGET = ld
endif

LDLIBS_TARGET = -L${ARMHF_SRC_HOME}/lib_target -lpthread -lrt

