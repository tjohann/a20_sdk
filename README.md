SDK for A20 devices (Cortex-A7)
===============================


A common development environment for ARMv7 boards based on Allwinners A20 processors. It provides basic component like compiler or env scripts. Additional you find all infos and bin/tools to setup one of the supported devices (see below). To make life easier you can use the scripts to clone useful external repositories like U-Boot, Linux and more.

As an extention you can install my sdk_builder (https://github.com/tjohann/sdk_builder) which should give you a gtk based tool at your hand. With that you can do all steps in a more simpler way by using a gui.


Requirement
-----------

The only yet know requirement is git.


Description
-----------

The a20_sdk use 2 different locations:

    /opt/a20_sdk


and

    /var/lib/a20_sdk



The location below /var/lib/ is the runtime environment. There you find all basic content you need. It's a git repository, so it's under version control and if i change something like supported kernel version, then i change it in the repository and you can pull these changes. See the NEWS file for those info.

Below /opt you find the downloaded content (http://sourceforge.net/projects/a20devices/) like toolchain and images. Additional you also find there all cloned external git repositories. This content will be updated or added depending on /var/lib/a20_sdk git repository. You can simply remove all if you dont need it anymore.


Setup
-----

Follow the steps below to setup your enviroment.



Create the two locations:

    mkdir /opt/a20_sdk
    mkdir /var/lib/a20_sdk


Change group to users and chmod it to 775:

    chgrp -R users /opt/a20_sdk
    chgrp -R users /var/lib/a20_sdk

    chmod 775 /opt/a20_sdk
    chmod 775 /var/lib/a20_sdk


Clone this repo to /opt/a20_sdk

    git clone https://github.com/tjohann/a20_sdk.git /opt/a20_sdk


Source the environment file armhf_env

    . ./armhf_env


or add it to your .bashrc 

    # setup the a20_sdk environment
    if [ -f /var/lib/a20_sdk/armhf_enf ]; then
      . /var/lib/a20_sdk/armhf_enf 
    fi


or copy armhf_env.sh to /etc/profile.d/

    sudo cp armhf_env.sh /etc/profile.d/


Init the SDK:

    make init_sdk


Download the compiler to /opt/a20_sdk/ :

    make get_toolchain


Download ALL images to /opt/a20_sdk/images/ :

    make get_image_tarballs


If you're only intrested in one device (like Cubietruck), then see the device specifics below.


Clone ALL external repos:

    make get_external_repos


Download latest supported kernel:

    make get_latest_kernel


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


You can find documenation on howto build a kernel or howto setup a device below Documenation. In general i will use mainline kernel and mainline U-Boot. Every device has a specific usecase. So there'fore you find addtional description about my usecase below.

In short:

    bananapi -> baalue (https://github.com/tjohann/baalue_sdk), my BAnanapi cAn bus cLUstEr
    bananapi-pro -> my home audio/video stream server 
    cubietruck -> master node for baalue and jailhouse (https://github.com/siemens/jailhouse) test environment
    olimex -> my conectivity "monster" (all A20 PINs are available!)


User
----

    root (password: root)
    baalue (password: baalue)
	

The user baalue is available on all images, it's the account for my BAnanapi cAn bus cLUstEr. You can use it to login via ssh.


Cubietruck (CB3)
----------------

My two cubietrucks are acting as a master node for my BAnanapi cAn bus cLUstEr. It is also my test environment for the jailhouse hypervisor. On this device i use mainline kernel in all images.


Additonal Hardware conneted:

    MCP25xx for CAN via SPI
    LCD1602 via I2C
    EEPROM ... vi SPI
    500GByte Harddisk (only on ONE device)


Addtional mount points:

    LABEL=KERNEL_CUBI   /mnt/cubietruck/cubietruck_kernel  auto  noauto,user,rw  0 0
    LABEL=ROOTFS_CUBI   /mnt/cubietruck/cubietruck_rootfs  auto  noauto,user,rw  0 0
    LABEL=HOME_CUBI     /mnt/cubietruck/cubietruck_home    auto  noauto,user,rw  0 0


Bananapi-Pro
------------

I use this device as an audio/video stream server. There'fore it's connected to my television and my audio amplifier. To have good 3D/GL power i use the sunxi kernel, but you can find mainline kernel config in configs. It also implements an home cloud via ownCloud. 


Addtional Harware connected:

    500GByte Harddisk for data storage


Addtional mount points:

    LABEL=KERNEL_BANA   /mnt/bananapi/bananapi_kernel      auto  noauto,user,rw  0 0
    LABEL=ROOTFS_BANA   /mnt/bananapi/bananapi_rootfs      auto  noauto,user,rw  0 0
    LABEL=HOME_BANA     /mnt/bananapi/bananapi_home        auto  noauto,user,rw  0 0


Bananapi-M1
-----------

The bananapi model 1 is the working node for my BAnanapi cAn bus cLUstEr. It has tty1-8 activated and lightdm on tty9. Also you find kernel and info rsyslogd output on tty11 and tty12. 


Additonal Hardware conneted:

    MCP25xx for second CAN via SPI
    LCD1602 via I2C
    CAN-Tranceiver on A20-CAN


Addtional mount points:

    LABEL=KERNEL_BANA   /mnt/bananapi/bananapi_kernel      auto  noauto,user,rw  0 0
    LABEL=ROOTFS_BANA   /mnt/bananapi/bananapi_rootfs      auto  noauto,user,rw  0 0
    LABEL=HOME_BANA     /mnt/bananapi/bananapi_home        auto  noauto,user,rw  0 0



Olimex A20-SOM/EVB
------------------

Additonal Hardware conneted:

    CAN-Tranceiver on A20-CAN
    tbd...
	  

Addtional mount points:

    LABEL=KERNEL_OLI    /mnt/olimex/olimex_kernel          auto  noauto,user,rw  0 0
    LABEL=ROOTFS_OLI    /mnt/olimex/olimex_rootfs          auto  noauto,user,rw  0 0
    LABEL=HOME_OLI      /mnt/olimex/olimex_home            auto  noauto,user,rw  0 0