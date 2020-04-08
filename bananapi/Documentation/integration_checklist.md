Integration - checklist for bananapi image (which is the master image)
======================================================================

This is a simple integration checklist for my a20_sdk. The purpose is to provied a repreducable delivery for the main versions (A20_SDK.X.X.0).

Below you find the common checks and the special tasks for A20_SDK.x.x.x.


Common checks
-------------

installation checks:

	- check bananapi-pro hdd installation (use make_sdcard.sh)
	- check cubietruck with hdd as baalue-master installation
	  (use make_sdcard.sh)
	- check olimex RT-PREEMPT installation (use make_sdcard.sh)

build/config updates on device (for base/normal image):

	- xbps-install -Su
	- reboot
	- xbps-remove -Oo
	- date > UPDATE_ROOTFS_DATE
	- cd a20_sdk && git pull
	- cp armhf_env.sh to /etc/profile.d
	- make mrproper
	- make init_sdk
	- /opt/a20_sdk/external (make get_base_repos && make build_base_repos)
	- /usr/src/jailhouse (git pull && make clean && make && sudo make install)
	- copy /home/baalue/src/ap6210/* to /lib/firmware/ap6210
	- updatedb

tool checks on device:

	- is network (ip) config correct
	- is jailhouse working
	  - olimex
	  - bananapi
	- i2c_gpio_driver_simple (bananapi)
	  modprobe i2c_gpio_driver_simple
	  usage_i2c_gpio_driver_simple ...
	- lcd1602 (cubietruck -> baalue-master)
	  modeprobe ...

sdk checks:

	- update checksum.sha256
	  (also: cp checksum.sha256 ${ARMHF_HOME}/a20_sdk/)




A20_SDK_V2.9.0 (xx.04.2020)
---------------------------

	Common checks                                         [2020-04-xx -> partly]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.8.2 (02.12.2018)
---------------------------

	Common checks                                         [2018-12-02 -> partly]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.8.1 (16.04.2018)
---------------------------

	Common checks                                         [2018-04-16 -> partly]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...



A20_SDK_V2.8.0 (09.02.2018)
---------------------------

	Common checks                                         [2018-02-09 -> partly]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.7.4 (05.02.2018)
---------------------------

	Common checks                                     [2018-02-05 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.7.3 (29.01.2018)
---------------------------

	Common checks                                     [2018-01-29 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.7.2 (28.01.2018)
---------------------------

	Common checks                                     [2018-01-28 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.7.1 (01.01.2018)
---------------------------

	Common checks                                     [2018-01-01 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.7.0 (19.11.2017)
---------------------------

	Common checks                                         [2017-11-19 -> partly]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.6.3 (30.10.2017)
---------------------------

	Common checks                                     [2017-10-30 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.6.2 (18.09.2017)
---------------------------

	Common checks                                     [2017-09-18 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.6.1 (10.09.2017)
---------------------------

	Common checks                                     [2017-09-10 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.6.0 (31.08.2017)
---------------------------

	Common checks                                         [2017-08-20 -> partly]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.5.0 (20.08.2017)
---------------------------

	Common checks                                         [2017-08-20 -> partly]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.4.1 (18.08.2017)
---------------------------

	Common checks                                     [2017-08-18 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- uboot for all devices
		- ...

	SDK updates:
		- make scripts aware of MY_HOST_ARCH
		- ...

	Others:
		- ...


A20_SDK_V2.4.0 (15.08.2017)
---------------------------

	Common checks                                         [2017-08-17 -> partly]

	Config updates (on the target):
		- ...

	Build updates:
		- uboot for all devices
		- ...

	SDK updates:
		- make scripts aware of MY_HOST_ARCH
		- ...

	Others:
		- ...


A20_SDK_V2.3.2 (15.08.2017)
---------------------------

	Common checks                                     [2017-08-15 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- uboot for all devices
		- ...

	SDK updates:
		- make scripts aware of MY_HOST_ARCH
		- ...

	Others:
		- ...


A20_SDK_V2.3.1 (29.07.2017)
---------------------------

	Common checks                                         [2017-07-29 -> partly]

	Config updates (on the target):
		- ...

	Build updates:
		- uboot for all devices
		- ...

	SDK updates:
		- make scripts aware of MY_HOST_ARCH
		- ...

	Others:
		- ...


A20_SDK_V2.3.0 (15.07.2017)
---------------------------

	Common checks                                         [2017-07-15 -> partly]

	Config updates (on the target):
		- ...

	Build updates:
		- uboot for all devices
		- ...

	SDK updates:
		- make scripts aware of MY_HOST_ARCH
		- ...

	Others:
		- ...


A20_SDK_V2.2.8 (12.07.2017)
---------------------------

	Common checks                                     [2017-07-12 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.2.7 (12.07.2017)
---------------------------

	Common checks                                     [2017-07-12 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.2.6 (11.07.2017)
---------------------------

	Common checks                                     [2017-07-11 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.2.5 (23.04.2017)
---------------------------

	Common checks                                     [2017-04-23 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.2.4 (15.03.2017)
---------------------------

	Common checks                                     [2017-03-15 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.2.3 (26.02.2017)
---------------------------

	Common checks                                     [2017-02-26 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.2.2 (11.02.2017)
---------------------------

	Common checks                                     [2017-02-11 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- Activate baalued on both images


A20_SDK_V2.2.1 (11.02.2017)
---------------------------

	Common checks                                     [2017-02-11 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.2.1 (XX.0X.2017)
---------------------------

	Common checks                                         [2017-XX-XX -> partly]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.2.0 (28.01.2017)
---------------------------

	Common checks                                         [2017-01-28 -> partly]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.1.1 (21.01.2017)
---------------------------

	Common checks                                     [2017-01-21 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.0.6/A20_SDK_V2.1.0 (28.12.2016)
------------------------------------------

	Common checks                                         [2016-12-16 -> partly]

	Config updates (on the target):
		- add emacs realted (ee.sh/...) config/scripts

	Build updates:
		- u-boot                                            [2016-11-02 -> done]
		- build emacs by hand (only full image)             [2016-12-16 -> done]

	SDK updates:
		- diskfree_sdcard.txt                               [2016-xx-xx -> done]
		- add base support for nanopi                       [2016-12-16 -> done]

	Others:
		- ...


A20_SDK_V2.0.5 (27.11.2016)
---------------------------

	Common checks                                     [2016-11-27 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.0.4 (11.11.2016)
---------------------------

	Common checks                                     [2016-11-11 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.0.3 (17.10.2016)
---------------------------

	Common checks                                     [2016-10-17 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.0.2 (13.10.2016)
---------------------------

	Common checks                                     [2016-10-13 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.0.1 (12.10.2016)
---------------------------

	Common checks                                     [2016-10-12 -> not needed]

	Config updates (on the target):
		- ...

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.0.0 (01.10.2016)
---------------------------

	Common checks                                         [2016-10-12 -> partly]

	Config updates (on the target):
		- ssh(d)_config                                     [2016-10-01 -> done]
		- hosts (another stack)                             [2016-10-01 -> done]
		- add pkgconfig.sh to /etc/profile.d                [2016-10-01 -> done]
		- add .Xresouces                                    [2016-10-01 -> done]

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...
