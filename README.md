SDK for A20 devices (Cortex-A7)
===============================


A common development environment for ARMv7 boards based on Allwinners A20 processor. It provides basic component like compiler, env scripts and more. Additional you find all infos and binary/tools to setup one of the supported devices (see below). To make life easier you can use the scripts to clone useful external repositories like U-Boot and more.

As an extention you can install my sdk_builder (https://github.com/tjohann/sdk_builder) which should give you a gtk based tool at your hand. With that you can do all steps in a more simpler way by using a gui.

WARNING: This is work in progress! So it's possible that something is not working or possibly not implemented yet. If you face a bug then pls use create an issue (https://github.com/tjohann/a20_sdk/issues).


Requirement
-----------

The only yet know requirements are git (to clone/update runtimedir), rsync (to sync content below workdir and srcdir) and dialog (if you want a tool to buildup your sdcard -> make_sdcard.sh).

For the two types of images ("normal" and "base/small") you need sd-cards with 4 or 8 gig of size.


Description
-----------

The a20_sdk use 3 different locations:

    /var/lib/a20_sdk
    /opt/a20_sdk
    ${HOME}/src/a20_sdk


The location below /var/lib/ is the runtime environment. There you find all basic content you need. It's a git repository, so it's under version control and if i change something like supported kernel version, then i change it in the repository and you can pull these changes. See the NEWS for those info.

Below /opt you find the downloaded content (http://sourceforge.net/projects/a20devices/) like toolchain and images. Additional you also find there all cloned external git repositories (/opt/a20_sdk/external). Also useful could be the download of kernel and RT-PREEMPT patch to /opt/a20_sdk/kernel. The whole content will be updated or added depending on /var/lib/a20_sdk git repository. You can simply remove all if you dont need it anymore (Note: make distclean removes all downloaded/untared content in the working dir /opt/a20_sdk).

The sdk comes with documentation and source code examples. You can find it in ${HOME}/src/a20_sdk/Documentation.


Setup
-----

Follow the steps below to setup your enviroment. If you use my sdk_builder (not finshed yet), then the tool will do this all for you.

Create the runtime locations:

    sudo mkdir /var/lib/a20_sdk

Change group to users and chmod it to 775:

    chown -R YOUR_USER_ACCOUNT:users /var/lib/a20_sdk
    chmod 775 /var/lib/a20_sdk

Clone this repo to /var/lib/a20_sdk

    git clone https://github.com/tjohann/a20_sdk.git /var/lib/a20_sdk

Source the environment file armhf_env

    . ./armhf_env

or add it to your .bashrc

    # setup the a20_sdk environment
    if [ -f /var/lib/a20_sdk/armhf_env ]; then
      . /var/lib/a20_sdk/armhf_env
    fi

or copy armhf_env.sh to /etc/profile.d/

    sudo cp armhf_env.sh /etc/profile.d/

Init the SDK:

    cd /opt/a20_sdk (or /var/lib/a20_sdk)
    make init_sdk

Download the compiler to /opt/a20_sdk/

    make get_toolchain

Download ALL images to /opt/a20_sdk/images/ (Note: this will download ~6 GByte)

    make get_image_tarballs

If you're only interested in one device (like Cubietruck), then you only need

	make get_cubietruck_image_tarballs

Clone ALL external repos:

    make get_external_repos

If you only need/want u-boot, then you only need

	cd /opt/a20_sdk/external
	make uboot

Download latest supported kernel sources (for normal use and with RT_PREEMPT support):

    make get_latest_kernel

if you only need/want the RT-PREEMPT parts, then you only need

	make get_latest_rt_kernel

Now you should have the complete content on your disk.


Update
------

I regulary update the images, toolchain and more. To stay up to date you can simply do the following steps.

Pull the latest changes:

    cd /var/lib/a20_sdk
    git pull

Take a look at the NEWS file to see what i've changed. See also UPGRADE_HINTS.

If there're changes of the toolchain, then fist distclean all:

    make distclean

and then proceed with the normal setup process above.

In short:

    make get_toolchain
    make get_latest_kernel (if needed)
    make get_image_tarballs (if needed)


Make a sd-card for a target device
----------------------------------

To make a ready to use sd-card (see also "Images" below) you can use the small dialog based tool avaiblable via

	./script/make_sdcard.sh

or

	make make_sdcard

It will guide you throught the process (see https://github.com/tjohann/a20_sdk/blob/master/scripts/Documentation/a20_sdk_make_sdcard.md).


Versioninfo
-----------

I use a standard version scheme via git tags based on 3 numbers:

	A20_SDK_V1.0.1

The first number is the mayor number which reflect bigger changes. The second number (minor) will change because of

	- new scripts
	- kernel/updates of all 4 devices

So a simple version update of the olimex kernel will not increase the minor number, instead it will increase the third number (age number):

	- bugfixes
	- update kernel versions only on one device
	- updates of on device images
	- all smaller changes


Storyline
---------

You find storylines for some of my usescases/devices below ./DEVICE_NAME/Documentation/storyline.md. They should describe the setup of a device and my usecase of it. You can use it as a guideline of howto.


All devices
-----------

Within /var/lib/a20_sdk/ you find the 4 supported devices below the directories (see /var/lib/a20_sdk/pics for some pictures of them)

    bananapi -> BananaPi-M1
    bananapi-pro -> BananaPi-Pro
    cubietruck -> Cubietruck (Cubieboard 3)
    olimex -> Olimex A20-SOM/EVB


Every device directory has the same sub-directories

    Documentation -> info about the device, howtos for kernel, U-Boot and more
    u-boot -> all U-Boot related content (*spl.bin, *.scr ...)
    etc -> example etc changes on the device (bananapi ... /etc/...)
    config -> kernel config for non-RT and RT-PREEMPT


You can find documenation on howto build a kernel or howto setup a device below Documenation. In general I will use mainline kernel and mainline U-Boot.
Every device here has a "specific usecase". So therefore you find additional description about my usecase below.

In short:

    bananapi -> baalue (my Bananapi Cluster with 8/10 Nodes)
    bananapi-pro -> my home audio/video stream server
    cubietruck -> master node for baalue and jailhouse (https://github.com/siemens/jailhouse) test environment
    olimex -> my conectivity "monster" (nearly all A20 PINs are available!) and jailhouse playground


Images
------

Two different versions of the images are supported:

	"normal" -> it's a large image with all important parts installed
	"base/small" -> it's a image where only base components are installed

You can think of the base/small image as a starting point for your individual device config. The images size also reflects the partition size, so you need at least 4 or 8 gig sd-cards.

A sd-card needs 3 different partitions which are reflected by the images tarballs itself:

	1). kernel (fat32/32 meg) -> bananapi_kernel.tgz/cubietruck_kernel.tgz/...
	2). rootfs (ext4/3 or 6 gig) -> a20_sdk_rootfs.tgz/a20_sdk_base_image.tgz
	3). home (ext4/ the rest) -> a20_sdk_home.tgz

The kernel images are device specific while all other images not.


User (images)
-------------

    root (password: root)
    baalue (password: baalue)


The user baalue is available on all images, you can use it to login via ssh and then use sudo or su -l for root tasks.


Kernel
------

Base-installation:

	Olimex -> RT-PREEMPT kernel
	Bananapi -> RT-PREEMPT
	Baalue-Node -> PREEMPT kernel
	Bananapi-Pro -> PREEMPT kernel (mainline)
	Cubietruck -> PREEMPT kernel

Note: with the upcomming new image scheme mainline kernel is supported (PREEMPT and RT-PREEMPT) on all devices.
Note 02: both kernel (RT-PREEMPT and PREEMPT) are supported on every device. If you want to use the other kernel than the base version, then copy no-rt or rt of $*SDCARD_KERNEL/*rt to $*SDCARD_KERNEL.


Network
-------

For testing purpose i have physical (and virtual -> QEMU based nodes) network where all devices are conneted to.

Single devices:

	192.168.0.100           arietta.my.domain               arietta
	192.168.0.101           cubietruck.my.domain            cubietruck
	192.168.0.102           olimex.my.domain		        olimex
	192.168.0.103	        bananapi.my.domain              bananapi
	192.168.0.109	        bananapi-pro.my.domain          bananapi-pro
	192.168.0.105           imx233.my.domain                imx233


My cluster:

	192.168.0.80            baalue-80.my.domain		        baalue-00
	192.168.0.81            baalue-81.my.domain      	    baalue-01
	192.168.0.82            baalue-82.my.domain      	    baalue-02
	192.168.0.83            baalue-83.my.domain      	    baalue-03
	192.168.0.84            baalue-84.my.domain      	    baalue-04
	192.168.0.85            baalue-85.my.domain      	    baalue-05
	192.168.0.86            baalue-86.my.domain      	    baalue-06
	192.168.0.87            baalue-87.my.domain      	    baalue-07
	192.168.0.90            baalue_master.my.domain     	baalue_master
	192.168.0.91            baalue_slave.my.domain      	baalue_slave


My nfs share:

	192.168.0.42            echnaton.my.domain              echnaton


Directory/File structure on sourceforge
---------------------------------------

All binary/big files (toolchain or images) are on sourceforge (https://sourceforge.net/projects/a20devices/files/). The scripts to setup the environment using that location to download them.

In the root directory you find the toolchain tarballs and the checksum.sh256 from the git-repository. The devices are represented through the named directorys. Below them you find only the kernel images. Due to the unified image approach the rootfs and home are below the directory named common.

Naming convention:

	toochain_x86_64.tgz/host_x86_64.tgz -> cross-toolchain for x86_64 hosts
	common/a20_sdk_*.tgz -> rootfs and home for all devices (master is bananapi) which need to be branded during make_sdcard.sh
	common/a20_sdk_base_rootfs.tgz -> this is the base/minimal rootfs
	bananapi/bananapi_kernel.tgz -> kernel image for the devices (bananapi)
	bananapi-pro/bananapi-pro_kernel.tgz -> kernel image for the devices (bananapi-pro)
	cubietruck/cubietruck_kernel.tgz -> kernel image for the devices (cubietruck)
	olimex/olimex_kernel.tgz -> kernel image for the devices (olimex)


Cubietruck (CB3)
----------------

My two cubietrucks are acting as master nodes for my Bananapi Cluster (cubietruck_master/cubietruck_slave). On the cubietruck_slave node everthing is on a sd-card, i use it also as 9th baalue-node or as the distribution node into the cluster (openmpi). So it act also as a possible master node although i named it cubietruck_slave. The node cubietruck_master has a hard-disk as root device. I use it mostly as distcc server node and the 8 cluster nodes as distcc clients.
The two cubietrucks are also my test environment for the jailhouse hypervisor. On this device i use mainline kernel in all images.


Additonal Hardware conneted:

    MCP25xx for CAN via SPI
    LCD1602 via I2C
    EEPROM ... vi SPI
    500GByte Harddisk (only on ONE device)


Addtional mount points (host):

    LABEL=KERNEL_CUBI   /mnt/cubietruck/cubietruck_kernel  auto  noauto,user,rw  0 0
    LABEL=ROOTFS_CUBI   /mnt/cubietruck/cubietruck_rootfs  auto  noauto,user,rw  0 0
    LABEL=HOME_CUBI     /mnt/cubietruck/cubietruck_home    auto  noauto,user,rw  0 0

    LABEL=SHARED_CUBI   /mnt/cubietruck/cubietruck_shared  auto  noauto,user,rw  0 0


Bananapi-Pro
------------

I use this device as an audio/video stream server. Therefore it's connected to my television and my audio amplifier. To have good 3D/GL power i use the sunxi kernel, but you can find mainline kernel config in configs. It also implements a home cloud via ownCloud.


Addtional Harware connected:

    500GByte Harddisk for data storage


Addtional mount points (host):

    LABEL=KERNEL_BANA   /mnt/bananapi/bananapi_kernel      auto  noauto,user,rw  0 0
    LABEL=ROOTFS_BANA   /mnt/bananapi/bananapi_rootfs      auto  noauto,user,rw  0 0
    LABEL=HOME_BANA     /mnt/bananapi/bananapi_home        auto  noauto,user,rw  0 0

    LABEL=SHARED_BANA   /mnt/bananapi/bananapi_shared      auto  noauto,user,rw  0 0


Bananapi-M1
-----------

I use the bananapi for 2 different usecase, first as a classic embedded device with can, display and other goodies. The second use case is as a baalue-node -> bananapi model 1 is the working node for my Bananapi Cluster. It has tty1-8 activated (and lightdm on tty9 -> if you activate it). Also you find kernel and info rsyslogd output on tty11 and tty12.

The main difference between these 2 usecases is the kernel. For a baalue-node i use the a PREEMPT kernel and for the classic device i use a RT-PREEMPT kernel.


Additonal Hardware conneted (as classic embedded device):

    MCP25xx for second CAN via SPI
    LCD1602 via I2C
    CAN-Tranceiver on A20-CAN


Addtional mount points (host):

    LABEL=KERNEL_BANA   /mnt/bananapi/bananapi_kernel      auto  noauto,user,rw  0 0
    LABEL=ROOTFS_BANA   /mnt/bananapi/bananapi_rootfs      auto  noauto,user,rw  0 0
    LABEL=HOME_BANA     /mnt/bananapi/bananapi_home        auto  noauto,user,rw  0 0

    LABEL=SHARED_BANA   /mnt/bananapi/bananapi_shared      auto  noauto,user,rw  0 0


Olimex A20-SOM/EVB
------------------

I use this device to play and test low level hardware because nearly all PINs of the A20 are available. It is also the test environment for my research about linux and realtime in general (see also https://github.com/tjohann/time_triggert_env.git).


Additonal Hardware conneted:

    CAN-Tranceiver on A20-CAN
    tbd...


Addtional mount points (host):

    LABEL=KERNEL_OLI    /mnt/olimex/olimex_kernel          auto  noauto,user,rw  0 0
    LABEL=ROOTFS_OLI    /mnt/olimex/olimex_rootfs          auto  noauto,user,rw  0 0
    LABEL=HOME_OLI      /mnt/olimex/olimex_home            auto  noauto,user,rw  0 0

    LABEL=SHARED_OLI    /mnt/olimex/olimex_shared          auto  noauto,user,rw  0 0


Development model
-----------------

I support only one version described by a tag (see checkout info above). The toolchain and images are for that version. Older tags wont be supported anymore. Starting with version A20_SDK_V2.0.0 further development will be done on a development branch (this means head is always ready to use).


Outlook (next development steps)
--------------------------------

(until mid of july -> done)
- Due to the fact that there's no real support for the sunxi kernel within my images i will remove them and concentrate on mainline kernel.

(until end of july -> done)
- There is some effort needed to unify all images over the different devices. The idea is to have only one base image (ROOT-Image -> Bananapi) and a script (./scripts/brand_image.sh) which copy/rsync the needed changes to the mounted sdcards.
- To make the usage a little bit easier i will provide a set of scripts to generate a ready to boot sd-card.
- Finally i provide dialog based script (make_sdcard.sh) to put all scipts (from above) together to a unified userinterface (handle image creation).
- I will provide a minimal image which could be the basic for your own systems (with PREEMPT and RT-PREEMPT kernel).

(until end of august)
- support for hdd installation

