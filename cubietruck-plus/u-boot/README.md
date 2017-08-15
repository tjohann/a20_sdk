# Howto deploy u-boot

## deploy to sdcard

`sudo dd if=u-boot-sunxi-with-spl.bin of=/dev/sdd bs=1024 seek=8`

## copy all to /mnt/cubietruck/cubietruck_kernel

`sudo cp u-boot-sunxi-with-spl.bin boot.cmd boot.scr /mnt/cubietruck/cubietruck_kernel/`
