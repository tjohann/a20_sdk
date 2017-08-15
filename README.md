SDK for A20 devices (Cortex-A7)
===============================


A simple development environment for ARMv7 boards based on Allwinners A20/H3/A83T/... processor. It provides basic component like compiler, env scripts (to set some environment variables like ${ARMHF_HOME}) and more. Additional you find all infos and binarys/tools to setup one of the supported devices (see below). To make life easier you can use the provided scripts to clone useful external repositories like u-boot or build a kernel for your device. To make a ready to use sd-card you can use a dialog based script which guide you through the process.

The basic user interface are make targets, which then start the corresponding scripts:

	+-----------------------------------------------------------+
    |                                                           |
    |                  Nothing to build                         |
    |                                                           |
    +-----------------------------------------------------------+
    | Example:                                                  |
    | make init_sdk           -> init all needed part           |
    | make get_external_repos -> get git repos like u-boot      |
    | make get_toolchain      -> install toolchain              |
    | make get_latest_kernel  -> download latest kernel version |
    | make get_image_tarballs -> download image tarballs        |
    | make get_all            -> get all of the above           |
    | make clean              -> clean all dir/subdirs          |
    | make distclean          -> complete cleanup/delete        |
    | make mrproper           -> do mrproper cleanup            |
    | make man                -> show a20_sdk manpage           |
    | ...                                                       |
    | make make_sdcard        -> small tool to make a read to   |
    |                            use SD-Card                    |
    | make install            -> install some scripts to        |
    |                            $(HOME)/bin                    |
    | make uninstall          -> remove scripts from            |
    |                            $(HOME)/bin                    |
    +-----------------------------------------------------------+

The sdk comes with documentation and some simple source code examples. You can find it in ${HOME}/src/a20_sdk/*.

WARNING: This is work in progress! So it's possible that something is not working as expected.

If you face a bug then pls use https://github.com/tjohann/a20_sdk/issues to create an issue.


Requirement
-----------

The only yet know software requirements are git (to clone/update runtimedir), rsync (to sync content below workdir and srcdir) and dialog (if you want a tool to make your sd-card -> a20_sdk_make_sdcard.sh).

For the two types of provided images ("normal" and "base/small") you need sd-cards with 10 or 6 gig of size. If you want to use a hdd it should be at least larger then 16 gig (i use 500 gig connected to my Cubietruck and Bananapi-Pro).


Background
----------

The a20_sdk use 3 different locations:

    /var/lib/a20_sdk (this git repository)
    /opt/a20_sdk
    ${HOME}/src/a20_sdk

The location below /var/lib/ is the "runtime" environment. There you find all base content like env file or scripts (see ./NEWS and ./UPGRADE_HINTS)

Below /opt/a20_sdk you find the downloaded content (from http://sourceforge.net/projects/a20devices/) like toolchain and device images. It also includes the standard location for cloned repositorys like u-boot or the kernel sources. Everthing could be done via a make target which then calls the coresponding script (see below for more info).


Setup
-----

You can use this sdk in different ways, depending on your use case, but you need some basic parts.

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

or copy armhf_env.sh to /etc/profile.d/ (the way I do it on the device images)

    sudo cp armhf_env.sh /etc/profile.d/

Init the SDK:

    cd /opt/a20_sdk (or /var/lib/a20_sdk)
    make init_sdk

Via

	make install

you install some script like make_sdcard.sh to ${HOME}/bin/a20_sdk_make_sdcard.sh

Note: to use all scripts, you have to add some mount points for your used device to your /etc/fstab and create the mount points below /mnt/ (see your prefered device below). It could also make sense to add your device to your /etc/hosts (see below for my example network configuration).


Additional steps to setup crossbuild environment
------------------------------------------------

Download the compiler to /opt/a20_sdk/

    make get_toolchain


Download images
---------------

Download ALL images to /opt/a20_sdk/images/ (Note: this will download ~8 GByte)

    make get_image_tarballs

If you only need/want the cubietruck images, the you only need

	cd /opt/a20_sdk/images
	make get_cubietruck_image_tarballs

Note: do a

	make

within /opt/a20_sdk/images to see what is additional supported.


Clone external repositorys
--------------------------

Clone ALL external repos:

    make get_external_repos

If you only need/want u-boot, then you only need

	cd /opt/a20_sdk/external
	make get_uboot

Note: do a

	make

within /opt/a20_sdk/external to see what is additional supported.


Get linux kernel sources
------------------------

Download latest supported kernel sources (for normal use and with **RT_PREEMPT** support):

    make get_latest_kernel

if you only need/want the **RT-PREEMPT** parts, then you only need

	make get_latest_rt_kernel

Note: do a

	make

within /opt/a20_sdk/kernel to see what is additional supported.


Update/Upgrade
--------------

I regulary update the images, toolchain and more. To stay up to date you can simply do the following steps.

Pull the latest changes:

    cd /var/lib/a20_sdk
    git pull

Take a look at the ./NEWS file to see what i've changed. See also ./UPGRADE_HINTS.

If there're changes of the toolchain, then first distclean all:

    make distclean

and then proceed with the normal setup process above.

In short:

    make get_toolchain
    make get_latest_kernel (if needed)
    make get_image_tarballs (if needed)

Sometimes it is needed to init the the whole sdk again (see ./UPGRADE_HINTS). Then simply do a

	make mrproper
	make init_sdk

and then the rest (if needed)

	make get_toolchain
    make get_latest_kernel (if needed)
    make get_image_tarballs (if needed)


Make a sd-card for a target device
----------------------------------

To make a ready to use sd-card (see also "Images" below) you can use the small dialog based tool avaiblable via

	make make_sdcard

or start

	a20_sdk_make_sdcard.sh

This will guide you throught the process ([Help of a20_sdk_make_sdcard.sh](scripts/Documentation/a20_sdk_make_sdcard.md)).


Prepare a HDD installation
--------------------------

To do a hdd installation you have first to setup a sd-card with the option hdd-preparation ([Help of a20_sdk_make_sdcard.sh](scripts/Documentation/a20_sdk_make_sdcard.md)). This will generate a sd-card with all needed tarballs on YOUR_FAVORITE_DEVICE_SDCARD_SHARED. The next step is to boot this sd-card and start another script wich will partition and install your connected hdd. If everthing went fine you now have a ready to use hdd but still missing a boot-only sd-card which you can setup (also) via (a20_sdk_)make_sdcard.sh.

See [Help of hdd_installation.sh](scripts/Documentation/hdd_installation.md) for more info.

Note: the size of the hdd-preparation sd-card should be at least 8 gig, the hdd-only sd-card could be small (it will carry only the boot partition and a small shared partition).


Internal flash
--------------

The cubietruck and the olimex have a flashchip soldered. The support for them via this sdk is on the TODO list.


Versioninfo
-----------

I use a standard version scheme via git tags based on 3 numbers:

	A20_SDK_V2.3.2

The first number is the mayor number which reflect bigger changes. The second number (minor) will change because of

	- new scripts
	- kernel/updates of all 4 devices (-> including new device images)

So a simple version update of the olimex kernel will not increase the minor number, instead it will increase the third number (age number):

	- bugfixes
	- update kernel versions only on one device (without new device images)
	- updates of only one device images
	- all smaller changes


Storyline
---------

You find storylines for some of my usescases/devices below ./DEVICE_NAME/Documentation/storyline.md. They should describe the setup of a device and my usecase of it. You can use them as something like guideline.

Note: Actually there not complete.


All devices
-----------

Within /var/lib/a20_sdk/ you find the 5 (+1) supported devices below the directories (see /var/lib/a20_sdk/pics for some pictures of them)

    bananapi -> BananaPi-M1
    bananapi-pro -> BananaPi-Pro
    cubietruck -> Cubietruck (Cubieboard 3)
	cubietruck-plus -> Cubietruck-Plus (Cubieboard 5)
    olimex -> Olimex A20-SOM/EVB
	nanopi -> NanoPi Neo (only basic support yet)

Every device directory has the same sub-directories

    Documentation -> info about the device, howtos for kernel, U-Boot and more
    u-boot -> all U-Boot related content (*spl.bin, *.scr ...)
    branding -> specific device branding like motd and dhcpd.conf
    config -> kernel config for **PREEMPT** and/or **RT-PREEMPT**

You can find documenation on howto build a kernel or howto setup a device below Documenation. In general I will use mainline kernel and mainline U-Boot. Every device here has a "specific usecase". So therefore you find additional description about my usecase below.

In short:

    bananapi -> baalue (my Bananapi Cluster with 8 Nodes) and embbedded plattform
    bananapi-pro -> my home audio/video stream server and nextcloud server
    cubietruck -> another possible baalue node node and test environment for jailhouse (https://github.com/siemens/jailhouse)
	cubietruck-plus -> my master node for baalue
    olimex -> my conectivity "monster" (nearly all A20 PINs are available!) and jailhouse playground
	nanopi -> base board for my mobile robots

My BAnAnapi cLUEster (Baalue):
![Alt text](pics/baalue_cluster.jpg?raw=true "Baalue")

My embedded environment:
![Alt text](pics/overview_embedded.jpg?raw=true "Overview embedded")


Images
------

Two different version of the images are supported:

	"normal" -> it's a large image with all important parts installed
	"base/small" -> it's a image where only base components are installed

You can think of the base/small image as a starting point for your individual device config. The images size also reflects the partition size, so you need at least 6 or 10 gig sd-cards.

A sd-card (for sd-card installation) needs 3 different partitions which are reflected by the images tarballs itself:

	1). kernel (fat32/32 meg) -> bananapi_(hdd_)kernel.tgz/cubietruck_(hdd_)kernel.tgz/...
	2). rootfs (ext4/6 or 10 gig) -> a20_sdk_rootfs.tgz/a20_sdk_base_image.tgz
	3). home (ext4/ the rest) -> a20_sdk_home.tgz


User
----

    root (password: root)
    baalue (password: baalue)

The user baalue is available on all images, you can use it to login via ssh and then use sudo or su -l for root tasks.


Kernel
------

Due to the fact that the devices are used for different task I support a mainline kernel with **PREEMPT** (instead of server or desktop) and a **RT-PREEMPT** (https://rt.wiki.kernel.org/index.php/Main_Page) patched kernel. In general all my kernel are huge ones with nearly everthing activated (which would make sense) and all important driver are build in the kernel (not as modul).

You find my configurations below the folder ${ARMHF_HOME}/YOUR_FAVORITE_DEVICE/configs. To build your own custom kernel you can use them as a base.

	Olimex -> RT-PREEMPT
	Bananapi -> PREEMPT
	Baalue-Node -> PREEMPT
	Bananapi-Pro -> PREEMPT
	Cubietruck -> PREEMPT
	Cubietruck-Plus -> PREEMPT
	NanoPi -> PREEMPT

Note: both kernel (**RT-PREEMPT** and **PREEMPT**) are supported on **every** device. If you want to use the other kernel, then copy rt or non-rt of ${YOUR_FAVORITE_DEVICE_SDCARD_KERNEL}/rt/* to ${YOUR_FAVORITE_DEVICE_SDCARD_KERNEL}.


Network
-------

For testing purpose i have a physical network where all devices are conneted to. The easiest way to use it is to add a usb-ethernet adapter to your main machine and add your target device to it, otherwise you have to change the configuration by hand.

Single devices:

	192.168.0.100           arietta.my.domain               arietta
	192.168.0.101           cubietruck.my.domain            cubietruck
	192.168.0.112           cubietruck-plus.my.domain       cubietruck-plus
	192.168.0.102           olimex.my.domain                olimex
	192.168.0.103	        bananapi.my.domain              bananapi
	192.168.0.109	        bananapi-pro.my.domain          bananapi-pro
	192.168.0.105           imx233.my.domain                imx233
	192.168.0.111           nanopi.my.domain                nanopi

My cluster:

	192.168.0.80            baalue-80.my.domain             baalue_master
	192.168.0.81            baalue-81.my.domain             baalue-01
	192.168.0.82            baalue-82.my.domain             baalue-02
	192.168.0.83            baalue-83.my.domain             baalue-03
	192.168.0.84            baalue-84.my.domain             baalue-04
	192.168.0.85            baalue-85.my.domain             baalue-05
	192.168.0.86            baalue-86.my.domain             baalue-06
	192.168.0.87            baalue-87.my.domain             baalue-07
	192.168.0.88            baalue-88.my.domain             baalue-08
	192.168.0.89            baalue-89.my.domain             baalue-09
	192.168.0.90            baalue-90.my.domain             baalue-10
	192.168.0.91            baalue-91.my.domain             baalue-11
	192.168.0.92            baalue-92.my.domain             baalue-12
	192.168.0.93            baalue-93.my.domain             baalue-13
	192.168.0.94            baalue-94.my.domain             baalue-14
	192.168.0.95            baalue-95.my.domain             baalue-15
	192.168.0.96            baalue-96.my.domain             baalue-16

My nfs share:

	192.168.0.42            echnaton.my.domain              echnaton


NFS share
---------

From my virtual device *echnaton* i share, via nfs some files. Also *baalue_master* can share the generated packages (see Distcc below) to the network. To active the *baalue_master* nfs share you can follow the void-linux instructions (https://wiki.voidlinux.eu/Network_filesystem). The base configuration is included in both images (base and full).


Distcc
------

To setup a build cluster based on this sdk you can addtional check https://github.com/tjohann/baalue_distcc . Here you should find all informations needed. Every base configuration is already included in both images (base and full).



Directory/File structure on sourceforge
---------------------------------------

All binary/big files (toolchain or images) reside on sourceforge (https://sourceforge.net/projects/a20devices/files/). The scripts to setup the environment using that location to download them.

In the root directory you find the toolchain tarballs and the checksum.sh256 from the git-repository. The devices are represented through the named directorys. Below them you find only the kernel images (for sdcard installation and hdd installation). Due to the unified image approach the rootfs and home are below the directory named common.

Naming convention:

	toochain_x86_64.tgz/host_x86_64.tgz -> cross-toolchain for x86_64 hosts
	common/a20_sdk_*.tgz -> rootfs and home for all devices which need to be branded during make_sdcard.sh
	common/a20_sdk_base_rootfs.tgz -> the base/minimal rootfs
	bananapi/bananapi_(hdd_)kernel.tgz
	bananapi/bananapi-pro_(hdd_)kernel.tgz
	bananapi/baalue_(hdd_)kernel.tgz
	cubietruck/cubietruck_(hdd_)kernel.tgz
	cubietruck/cubietruck-plus_(hdd_)kernel.tgz
	olimex/olimex_(hdd_)kernel.tgz
	nanopi/nanopi_kernel.tgz


Cubietruck (CB3) and Cubietruck-Plus (CB5)
------------------------------------------

One of my two cubietruck (the cubietruck-plus) is acting as master nodes for my Bananapi Cluster (baalue_master). The baalue_master has a hard-disk as boot device. I use it as a distcc server node and the 8 cluster nodes as distcc clients. It has a pcb with some additional hardware connected.

The cubietruck's are also my test environment for the jailhouse hypervisor.

Cubietruck 3 vs Cubietruck 5:
![Alt text](pics/cubietruck_3_vs_5.jpg?raw=true "Find the difference")

Additonal Hardware conneted:

    MCP25xx for CAN via SPI
    LCD1602 and PCF8574 via I2C
    EEPROM vi SPI
    500 GByte Harddisk

Addtional mount points (host):

    LABEL=KERNEL_CUBI   /mnt/cubietruck/cubietruck_kernel  auto  noauto,user,rw  0 0
    LABEL=ROOTFS_CUBI   /mnt/cubietruck/cubietruck_rootfs  auto  noauto,user,rw  0 0
    LABEL=HOME_CUBI     /mnt/cubietruck/cubietruck_home    auto  noauto,user,rw  0 0

    LABEL=SHARED_CUBI   /mnt/cubietruck/cubietruck_shared  auto  noauto,user,rw  0 0

[The storyline for Cubietruck](cubietruck/Documentation/storyline.md)

[The storyline for Cubietruck-Plus](cubietruck-plus/Documentation/storyline.md)


Bananapi-Pro
------------

I use this device as an audio/video stream server. Therefore it's connected to my television and my audio amplifier. It also provide a home cloud via Nextcloud (https://nextcloud.com/install/).

Addtional Hardware connected:

    500GByte Harddisk for data storage

Additional mount points (host):

    LABEL=KERNEL_BANA   /mnt/bananapi/bananapi_kernel      auto  noauto,user,rw  0 0
    LABEL=ROOTFS_BANA   /mnt/bananapi/bananapi_rootfs      auto  noauto,user,rw  0 0
    LABEL=HOME_BANA     /mnt/bananapi/bananapi_home        auto  noauto,user,rw  0 0

    LABEL=SHARED_BANA   /mnt/bananapi/bananapi_shared      auto  noauto,user,rw  0 0

[The storyline for Cubietruck](bananapi-pro/Documentation/storyline.md)


Bananapi-M1
-----------

I use the bananapi in 2 different ways:

	- as a embedded device with can, display and other goodies
	- a baalue-node

The main difference between these 2 usecases is the kernel. For a baalue-node i use the a **PREEMPT** kernel and for the classic device i also use a **RT-PREEMPT** kernel.

Additonal Hardware conneted (as classic embedded device):

    MCP25xx for second CAN via SPI
    LCD1602 via I2C
    CAN-Tranceiver on A20-CAN

Addtional mount points (host):

    LABEL=KERNEL_BANA   /mnt/bananapi/bananapi_kernel      auto  noauto,user,rw  0 0
    LABEL=ROOTFS_BANA   /mnt/bananapi/bananapi_rootfs      auto  noauto,user,rw  0 0
    LABEL=HOME_BANA     /mnt/bananapi/bananapi_home        auto  noauto,user,rw  0 0

    LABEL=SHARED_BANA   /mnt/bananapi/bananapi_shared      auto  noauto,user,rw  0 0

[The storyline for Bananapi](bananapi/Documentation/storyline.md)


Baalue
------

Baalue is my bananapi cluster where I want to learn more about distributed system and the coresponding development models. The actual configuration has 8 Bananapi-M1 nodes and on master node based on a Cubietruck (CB3). I the near future there will be an update with an additional stack of 8 Bananapi-M1 and a Pine64 as master node .

The script (a20_sdk_)make_sdcard.sh can generate a baalue node base image which is a specialized bananapi images. If you want to build your own cluster this could be a good starting point. What you then have to change is only the ip and the hostname (see folder baalue/branding/etc_1/ as an example).

There'se also a script called brand_baalue_images.sh in ./scripts. This will brand your image based on my topologie (ip and so one). But this script wont care about *my* used device. So you can build a olimex based cluster with my topologie instead of bananapi. (Note: the script wont change the kernel, so if you use olimex you will have a *RT-PREEMPT* kernel).

	+--------------------------------------------------------+
	| Usage: brand_baalue_images.sh                          |
	|        [-b] -> bananapi/bananapi-pro/olimex/baalue/    |
	|                cubietruck/cubietruck-plus/nanopi       |
	|        [-n] -> node (1...16, master)                   |
	|        [-s] -> prepare images for hdd installation     |
	|        [-v] -> print version info                      |
	|        [-h] -> this help                               |
	|                                                        |
	+--------------------------------------------------------+

A possible project where I want to use the cluster and distributed calculation is with my robot-cluster env (see baalue/Documentation/robot_cluster_env.pdf for more info about it).

My BAnAnapi cLUEster (Baalue):
![Alt text](pics/bananapi_cubietruck_cluster.jpg?raw=true "Baalue")

[The storyline for Baalue](baalue/Documentation/storyline.md)


Olimex A20-SOM/EVB
------------------

I use this device to play and test low level hardware because nearly all PINs of the A20 are available. It is also the test environment for my research about linux and realtime in general (see also https://github.com/tjohann/time_triggert_env.git).

Additonal Hardware conneted:

    CAN-Tranceiver on A20-CAN
    LCD1602 via I2C
	GPIO-I2C via PCF8574
	Ultrasonic sensor
	GPS via uart
	... a lot more

Addtional mount points (host):

    LABEL=KERNEL_OLI    /mnt/olimex/olimex_kernel          auto  noauto,user,rw  0 0
    LABEL=ROOTFS_OLI    /mnt/olimex/olimex_rootfs          auto  noauto,user,rw  0 0
    LABEL=HOME_OLI      /mnt/olimex/olimex_home            auto  noauto,user,rw  0 0

    LABEL=SHARED_OLI    /mnt/olimex/olimex_shared          auto  noauto,user,rw  0 0

[The storyline for Olimex](olimex/Documentation/storyline.md)


NanoPi Neo
----------

I use this device as my base board for mobile robotics because of the size and cpu power (4 core)

Addtional Hardware connected:

    DC motor controller
	Ultrasonic sensor
	USB camera
	... (sensor/actors for robotic)

Additional mount points (host):

    LABEL=KERNEL_NANO   /mnt/nanopi/nanopi_kernel      auto  noauto,user,rw  0 0
    LABEL=ROOTFS_NANO   /mnt/nanopi/nanopi_rootfs      auto  noauto,user,rw  0 0
    LABEL=HOME_NANO     /mnt/nanopi/nanopi_home        auto  noauto,user,rw  0 0

    LABEL=SHARED_NANO   /mnt/nanopi/nanopi_shared      auto  noauto,user,rw  0 0

[The storyline for Nanopi](nanopi/Documentation/storyline.md)


Notes about /opt/a20_sdk/external
---------------------------------

This repository is something like a bracket over my differnet projects and so below ${ARMHF_BIN_HOME} is the place for them. Most parts (like libbaalue.git or time_triggert_env.git) are already installed on the images i provide. I use the devices as my test and development plattform (see also ./pics).

If you're interested in realtime linux (for example) you should have then a good basement for your own development.


Development model
-----------------

I support only one version described by a tag. The toolchain and images are for that version. Older tags wont be supported anymore.

For every delivery i have something like a integration/delivery checklist ([Integration/Delivery checklist](bananapi/Documentation/integration_checklist.md)).


Outlook (next development steps)
--------------------------------

Note: This repository is something like a bracket over my differnet projects. So not every point below will end in changes within this repository.


(future steps)
- add storyline for bananapi-pro (home cloud server)
- make use of lcd1602 module of cubietruck (baalue_master)
- make all scripts "self hosting" so that all scripts would also run on the target device (like build_kernel.sh running on baalue_master)
- add dtc config for mcp2515 (bananapi and cubietruck)
- working jailhouse configuration for bananapi and olimex
- simple example for using bare-metal cell within bananapi/olimex
- working can parts for a20-can and mcp2515 (bananapi/olimex)
- working can baremetal can example
- simple baremetal lcd example
- support flashchip of olimex and/or cubietruck
- simple os for baremetal cell (see https://github.com/tjohann/miblos)
- add storyline for nanopi as part of a mobile robot
