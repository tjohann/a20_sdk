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
	- check bananapi RT-PREEMPT installation (use make_sdcard.sh)

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

tool checks on device:

	- is jailhouse working
	  - olimex
	  - bananapi
	- i2c_gpio_driver_simple
	  modprobe i2c_gpio_driver_simple
	  usage_i2c_gpio_driver_simple ...

sdk checks:

	- update checksum.sha256
	  (also: cp checksum.sha256 ${ARMHF_HOME}/a20_sdk/)


A20_SDK_V2.0.0 (xx.10.2016)
---------------------------

	Common checks                                          [2016-10-01 -> mostly]

	Config updates (on the target):
		- ssh(d)_config                                      [2016-10-01 -> done]
		- hosts (another stack)                              [2016-10-01 -> done]
		- add pkgconfig.sh to /etc/profile.d                 [2016-10-01 -> done]
		- add .Xresouces                                     [2016-10-01 -> done]

	Build updates:
		- ...

	SDK updates:
		- ...

	Others:
		- ...


A20_SDK_V2.1.0 (xx.xx.2016)
---------------------------

	Common checks                                            [2016-XX-XX -> xxxx]

	Config updates (on the target):
		- add emacs realted (ee.sh/...) config/scripts

	Build updates:
		- u-boot

	SDK updates:
		- diskfree_sdcard.txt

	Others:
		- add dts support for mcp2515 (CAN)
