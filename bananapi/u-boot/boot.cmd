fatload mmc 0 0x46000000 uImage
fatload mmc 0 0x49000000 sun7i-a20-bananapi.dtb
setenv bootargs console=ttyS0,115200 loglevel=9 <earlyprintk> mem=960M vmalloc=512M root=/dev/mmcblk0p2 rootwait panic=10 
bootm 0x46000000 - 0x49000000
