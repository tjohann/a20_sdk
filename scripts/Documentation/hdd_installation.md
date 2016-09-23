The hdd_installation script
===========================

This is a simple howto on using the hdd_installation.sh script to make a working hdd-installation.


Preparation
-----------

First you have to create a installation medium via a20_sdk_make_sdcard.sh script. Choose the normal options like device node (/dev/hdd or ...) and the target (Bananapi-Pro/...), additionally you have to choose the hdd-preparation option. Then you take the normal steps and after all you have a bootable sd-card whith all needed tarballs on it.

Note: You can also choose which rootfs you want (base or normal). This will be installed on your hdd. Pls also note that the sd-card must be large enough to hold everthing. So i would recommend at least a 8 gig sd-card for the installation process.


Host part
---------

After creation plug the sd-card into and boot, ssh on it ...

KDO:

	ssh -l baalue bananapi-pro
	su -l  (there's no $HOME)
	mount /mnt/bananapi/bananapi_shared/  (here are the tarballs)
	cd /mnt/bananapi/bananapi_shared/


Content:

	lf /mnt/bananapi/bananapi_shared/
	total 961M
	drwxr-xr-x 4 root root 4.0K Aug 23 19:35 ./
	drwxr-xr-x 3 root root 4.0K Aug 15 11:40 ../
	-rw-r--r-- 1 root root 943M Aug 23 19:32 a20_sdk_base_rootfs.tgz
	-rw-r--r-- 1 root root 754K Aug 23 19:32 a20_sdk_home.tgz
	-rw-r--r-- 1 root root  17M Aug 23 19:32 bananapi-pro_kernel.tgz
	drwxr-xr-x 2 root root 4.0K Aug 23 19:35 hdd_boot/
	-rw-r--r-- 1 root root  411 Aug 23 19:35 hdd_branding.tgz
	-rwxr-xr-x 1 root root 7.7K Aug 23 19:42 hdd_installation.sh*
	drwx------ 2 root root  16K Aug 23 19:27 lost+found/


![Alt text](pics/hdd_installation_host_part.png?raw=true "...")


Target part
-----------

The installation should be quite simple. It first creates the needed partitions, then untars the different content and brand all

KDO:

	root@bananapi-pro:/mnt/bananapi/bananapi_shared# ./hdd_installation.sh


![Alt text](pics/hdd_installation_script.png?raw=true "...")


Pls check the output, maybe some interaction (presse enter of y) of you is needed (if there already partions available).


Finalize
---------

After the installation process you have to create a hdd-boot-only sd-card (again via a20_sdk_make_sdcard.sh). This one holds only the boot partition and therefore it could be a 1 gig or whatever you have laying around.

With this sd-card you can boot from hdd.
