fatload mmc 0 0x46000000 uImage
fatload mmc 0 0x49000000 sun8i-a83t-cubietruck-plus.dtb
setenv bootargs console=ttyS0,115200 console=tty0 loglevel=9 <earlyprintk> mem=1984M vmalloc=512M root=/dev/mmcblk0p2 rootwait panic=10
bootm 0x46000000 - 0x49000000
