fatload mmc 0 0x46000000 uImage
fatload mmc 0 0x49000000 sun8i-h3-nanopi-neo.dtb
setenv bootargs console=ttyS0,115200 console=tty0 loglevel=9 <earlyprintk> mem=960M vmalloc=512M root=/dev/sda1 rootwait panic=10
bootm 0x46000000 - 0x49000000
