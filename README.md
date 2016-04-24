SDK for A20 devices (Cortex-A7)
===============================


A common development environment for ARMv7 boards based on Allwinners A20 processor. It provides basic component like compiler, env scripts and more. Additional you find all infos and binary/tools to setup one of the supported devices (see below). To make life easier you can use the scripts to clone useful external repositories like U-Boot and more.

As an extention you can install my sdk_builder (https://github.com/tjohann/sdk_builder) which should give you a gtk based tool at your hand. With that you can do all steps in a more simpler way by using a gui.


Requirement
-----------

The only yet know requirements are git (to clone/update runtimedir) and rsync (to sync content below workdir and srcdir).


Description
-----------

The a20_sdk use 3 different locations:

	/var/lib/a20_sdk
    /opt/a20_sdk
	${HOME}/src/a20_sdk


The location below /var/lib/ is the runtime environment. There you find all basic content you need. It's a git repository, so it's under version control and if i change something like supported kernel version, then i change it in the repository and you can pull these changes. See the NEWS for those info.

Below /opt you find the downloaded content (http://sourceforge.net/projects/a20devices/) like toolchain and images. Additional you also find there all cloned external git repositories (/opt/a20_sdk/external). Also useful could be the download of kernel and RT-PREEMPT patch to /opt/a20_sdk/kernel. The whole content will be updated or added depending on /var/lib/a20_sdk git repository. You can simply remove all if you dont need it anymore (Note: make distclean removes all downloaded/untared content in the working dir /opt/a20_sdk).

The sdk comes with documentation and source code examples. You can find it in ${HOME}/src/a20_sdk (docs also in /opt/a20_sdk/Documentation).


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


You can find documenation on howto build a kernel or howto setup a device below Documenation. In general i will use mainline kernel and mainline U-Boot.
Every device here has a "specific usecase". So therefore you find additional description about my usecase below.

In short:

    bananapi -> baalue (my Bananapi Cluster with 8/10 Nodes)
    bananapi-pro -> my home audio/video stream server 
    cubietruck -> master node for baalue and jailhouse (https://github.com/siemens/jailhouse) test environment
    olimex -> my conectivity "monster" (nearly all A20 PINs are available!)


User
----

    root (password: root)
    baalue (password: baalue)
	

The user baalue is available on all images, you can use it to login via ssh.


Kernel
------

	Olimex -> RT-PREEMPT and PREEMPT kernel
	Bananapi -> RT-PREEMPT
	Baalue-Node -> PREEMPT kernel
	Bananapi-Pro -> "normal" desktop kernel (sunxi-kernel) and PREEMPT kernel (mainline)
	Cubietruck -> PREEMPT kernel
	
	
Network
-------

For testing purpose i have physical network where all devices are conneted to.

Single devices:

	192.168.0.100           arietta.my.domain               arietta
	192.168.0.101           cubietruck.my.domain            cubietruck
	192.168.0.102           olimex.my.domain			    olimex
	192.168.0.103		    bananapi.my.domain			    bananapi
	192.168.0.105           imx233.my.domain                imx233


My cluster:

	192.168.0.80            bananapi-80.my.domain      		bananapi-80
	192.168.0.81            bananapi-81.my.domain      		bananapi-81
	192.168.0.82            bananapi-82.my.domain      		bananapi-82
	192.168.0.83            bananapi-83.my.domain      		bananapi-83
	192.168.0.84            bananapi-84.my.domain      		bananapi-84
	192.168.0.85            bananapi-85.my.domain      		bananapi-85
	192.168.0.86            bananapi-86.my.domain      		bananapi-86
	192.168.0.87            bananapi-87.my.domain      		bananapi-87
	192.168.0.90            cubietruck_master.my.domain     cubietruck_master
	192.168.0.91            cubietruck_slave.my.domain      cubietruck_slave


My nfs share:

	192.168.0.42            echnaton.my.domain              echnaton



Cubietruck (CB3)
----------------

My two cubietrucks are acting as a master nodes for my Bananapi Cluster (cubietruck_master/cubietruck_slave). On the cubietruck_slave node everthing is on a sd-card, i use it also as 9th baalue-node or as the distribution node into the cluster (openmpi). So it act also as a possible master node although i named it cubietruck_slave. The node cubietruck_master has a hard-disk as root device. I use it mostly as distcc server node and the 8 cluster nodes as distcc clients. 
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


Bananapi-Pro
------------

I use this device as an audio/video stream server. Therefore it's connected to my television and my audio amplifier. To have good 3D/GL power i use the sunxi kernel, but you can find mainline kernel config in configs. It also implements a home cloud via ownCloud. 


Addtional Harware connected:

    500GByte Harddisk for data storage


Addtional mount points (host):

    LABEL=KERNEL_BANA   /mnt/bananapi/bananapi_kernel      auto  noauto,user,rw  0 0
    LABEL=ROOTFS_BANA   /mnt/bananapi/bananapi_rootfs      auto  noauto,user,rw  0 0
    LABEL=HOME_BANA     /mnt/bananapi/bananapi_home        auto  noauto,user,rw  0 0


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
