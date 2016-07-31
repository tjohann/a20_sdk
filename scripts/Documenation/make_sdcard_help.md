Help info for make_sdcard.sh
============================

This tool should help you to make a ready-to-use sd-card for your prefered target device supported
by the a20_sdk.


Supported target devices
------------------------

These are the supported target devices:

	Bananapi-M1 (normal and Baalue-Cluster-Node)
	Bananapi-Pro
	Cubietruck (Cubieboard 3)
	Olimex-SOM-EVB


Preparation
-----------

This is a stupid tool, so you have to provide some informations to it. One of it is the device
node of your sd-card. So pls plug it in and check the entry in /var/log/messages. You should see
something like /dev/sdd or /dev/mmcblk0 or so. This value is the input of the device node entry
of the configuration menu.


Usage
-----

You can start the tool via make target

    make make_sdcard

or direct via

   cd ${ARMHF_HOME}/scripts
   ./make_sdcard.sh

To write a bootloader you need sudo rights. Therefore the tool ask for it at the beginning and a
small task in the background keep the access rights alive (see ps aux | grep make_sdcard). In
general it will only use sudo if it's really needed and not in general (make_sdcard.sh wont run
with sudo rights).

First you have to give all configuration values needed to the tool. Open the configuration menu
entry and choose at least the device node (see /var/log/messages after you plugin the sd-card)
and the target device (Bananapi/.../Olimex). It's also possible to choose a minimal (base) image
and/or the preparation of an sd-card for HDD installation. Finally you can take a look at your
inputs via menu entry 'show actual configuration'.

Next step is to download the images from sourceforge. This will take a while! To see what will
be done, you can start the logging via menu entry or do a

   tail -n 50 -f make_sdcard.log

You can find the images below ${ARMHF_BIN_HOME/images/}.

After download you can choose the sd-card menu. There you have to do the task

   1). partition and format the sd-card
   2). write image to sd-card
   3). write bootloader to sd-card
   4). brand sd-card

Now you should have a ready to use sd-card for your choosen target device.


Simple usage
------------

To make it a little bit easier, you can choose the main menu entry 'Do all steps in line' which
calls all needed parts in the right order. But be aware, the error handling is far from perfect!



