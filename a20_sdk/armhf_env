# +--------------------- setup the armhf dev environment ----------------------+
# |                                armhf_env                                   |
# +----------------------------------------------------------------------------+

# set MY_HOST_ARCH
export MY_HOST_ARCH=$(uname -m)

# set supported kernel version
export ARMHF_KERNEL_VER=4.6.7
export ARMHF_RT_KERNEL_VER=4.6.7
export ARMHF_RT_VER=rt13

# home of the git repo
export ARMHF_HOME=/var/lib/a20_sdk
# home of the bin's
export ARMHF_BIN_HOME=/opt/a20_sdk
# home of src examples
export ARMHF_SRC_HOME=$HOME/src/a20_sdk

# extend PATH for our a20 stuff
export PATH=$PATH:${ARMHF_BIN_HOME}/toolchain/bin:${ARMHF_BIN_HOME}/host/usr/bin

# set mount points for the sdcard -> bananapi-(M1/PRO)
export BANANAPI_SDCARD_KERNEL=/mnt/bananapi/bananapi_kernel
export BANANAPI_SDCARD_ROOTFS=/mnt/bananapi/bananapi_rootfs
export BANANAPI_SDCARD_HOME=/mnt/bananapi/bananapi_home
export BANANAPI_SDCARD_SHARED=/mnt/bananapi/bananapi_shared

# set mount points for the sdcard -> olimex
export OLIMEX_SDCARD_KERNEL=/mnt/olimex/olimex_kernel
export OLIMEX_SDCARD_ROOTFS=/mnt/olimex/olimex_rootfs
export OLIMEX_SDCARD_HOME=/mnt/olimex/olimex_home
export OLIMEX_SDCARD_SHARED=/mnt/olimex/olimex_shared

# set mount points for the sdcard -> cubietruck
export CUBIETRUCK_SDCARD_KERNEL=/mnt/cubietruck/cubietruck_kernel
export CUBIETRUCK_SDCARD_ROOTFS=/mnt/cubietruck/cubietruck_rootfs
export CUBIETRUCK_SDCARD_HOME=/mnt/cubietruck/cubietruck_home
export CUBIETRUCK_SDCARD_SHARED=/mnt/cubietruck/cubietruck_shared

echo "Setup env for host \"${MY_HOST_ARCH}\" with root dir \"${ARMHF_HOME}\" and bin root dir \"${ARMHF_BIN_HOME}\""

#EOF
