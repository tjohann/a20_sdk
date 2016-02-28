# Howto deploy u-boot

## deploy to sdcard

`sudo dd if=u-boot-sunxi-with-spl.bin of=/dev/sdd bs=1024 seek=8`

## copy all to /mnt/olimex/olimex_kernel

`sudo cp u-boot-sunxi-with-spl.bin boot.cmd boot.scr /mnt/olimex/olimex_kernel/`
