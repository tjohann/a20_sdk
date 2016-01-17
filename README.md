a20_sdk
=======


A common development environment for ARMv7 boards based on Allwinners A20. It provides basic parts like compiler or env scripts.


Cubietruck (CB3)
----------------


	LABEL=KERNEL_CUBI   /mnt/cubietruck/cubietruck_kernel  auto  noauto,user,rw  0 0
	LABEL=ROOTFS_CUBI   /mnt/cubietruck/cubietruck_rootfs  auto  noauto,user,rw  0 0
	LABEL=HOME_CUBI     /mnt/cubietruck/cubietruck_home    auto  noauto,user,rw  0 0


Bananapi-M(1/pro)
-----------------


	LABEL=KERNEL_BANA   /mnt/bananapi/bananapi_kernel      auto  noauto,user,rw  0 0
	LABEL=ROOTFS_BANA   /mnt/bananapi/bananapi_rootfs      auto  noauto,user,rw  0 0
	LABEL=HOME_BANA     /mnt/bananapi/bananapi_home        auto  noauto,user,rw  0 0


Olimex A20-SOM/EVB
------------------


	LABEL=KERNEL_OLI    /mnt/olimex/olimex_kernel          auto  noauto,user,rw  0 0
	LABEL=ROOTFS_OLI    /mnt/olimex/olimex_rootfs          auto  noauto,user,rw  0 0
	LABEL=HOME_OLI      /mnt/olimex/olimex_home            auto  noauto,user,rw  0 0