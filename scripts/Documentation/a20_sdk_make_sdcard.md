The make_sdcard/a20_sdk_make_sdcard script
==========================================

This is a simple howto on using the make_sdcard.sh/a20_sdk_make_sdcard.sh to make a working sd-card.


Main menu
---------

Within the main menu you first have input some configuration values, then download the images and finally make a sd-card. So the first menu point to enter is the configuration menu.

![Alt text](pics/main_menu.png?raw=true "...")

Due to the nature of dialog (the library used for the graphical parts) it's not really possible to do something like an logging window or addtionally get progress from the scripts. So to see the output of the scripts use the menu entry logging of the main menu or tail -f /tmp/*make_sdcard_PID.log.

The menu entry do all steps in line will step through all needed menu parts one after another, but I would recommend to do it manually for the first time to see if everthing is working correct. Afterwords you can use that menuentry for a fast make of a sd-card.


Config menu
-----------

Within the configuration menu you can enter some inputs for the scripts which afterwards will be executed by the menu entrys below. At least you have to enter the device node of your sd-card and the device to use.

![Alt text](pics/config_menu.png?raw=true "...")

To find out on which device node your sd-card appears, plug it in and check /var/log/messages for an entry like

	SNIP
	xxxxx echnaton kernel: [15516.292219] sd 9:0:0:0: [sdd] Attached SCSI removable disk

In this case the sd-card is allocated as sdd, so this is the input.

![Alt text](pics/enter_devnode.png?raw=true "...")

The next step is to choose a device.

![Alt text](pics/select_target.png?raw=true "...")

Finally you can take a look on your inputs via show actual configuration menuentry. The last two lines are only relevant if you want to use the base image instead of the normal and/or you want to do make a installation media for hdd installation (see my cubietruck usecase).

![Alt text](pics/actual_config.png?raw=true "...")


Download images
---------------

Based on the configuration the script will download all needed images and place them in /opt/a20_sdk/images.

![Alt text](pics/download_images.png?raw=true "...")


Sd-card menu
------------

To create a ready to use sd-card go to the sdcard_menu.

![Alt text](pics/sdcard_menu.png?raw=true "...")

The fist step is to partition and format the sd-card. The input like device node and target device (file system LABEL) will come from the configuration menu.

![Alt text](pics/partition_sdcard.png?raw=true "...")

In the next step you write the downloaded tarballs to the sd-card and brand the it for Cubietruck or the other supported target devices.

![Alt text](pics/write_image.png?raw=true "...")

![Alt text](pics/brand_sdcard.png?raw=true "...")

The final step is to write the bootloader (U-Boot) to the sd-card.

![Alt text](pics/write_bootloader.png?raw=true "...")
