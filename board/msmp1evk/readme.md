ARIES Embedded module MSMP1 on Evaluation Kit MSMP1EVK
========================================================================

Introduction
------------

This README describes how to build and install the firmware for the
ARIES Embedded System on Module (SoM) [MSMP1][1] and the Evaluation Kit
(EVK) [MSMP1EVK][2].


Build
-----

How to build the BSP images is described in the [README.md][3] file in the
top directory of this repository.


SPI-NOR and SDcard/eMMC Layout
------------------------------

The layout is defined by `genimage.cfg`. The SPI-NOR is partitioned
as show below:

      Offset   Size  Image
    0x000000   256K  fsbl1
    0x040000   256K  fsbl2
    0x080000     4M  fip
    0x480000   512K  u-boot-env
    0x500000     9M  nor_user

And for the SDcard/eMMC the following partitions are created:

    Number  Start (sector)    End (sector)  Size Name
         1              34             545  256K fsbl1
         2             546            1057  256K fsbl2
         3            1058            9249 4096K fip
         4            9250          132129 60.0M rootfs


Images
------

The following files are generated in the `images` sub-directory:

- For partition "fsbl1" and "fsbl2":

      tf-a-stm32mp157a-msmp1evk.stm32  # Arm Trusted Firmware image

- For partition "fip":

      fip.img                          # FIP image

- For Partition "rootfs":

      rootfs.ext4                      # Root filesystem EXT4 image

- For NFS:

      zImage                           # Linux kernel image
      stm32mp157a-msmp1evk.dtb         # Device Tree Binary
      rootfs.tar.bz2                   # Root filesystem archive

- Full SDcard/eMMC image:

      sdcard.img                       # overall SDcard/eMMC image

- Image for the SPI-NOR:

      spi-nor.img                      # overall Boot-loader image


Create a bootable microSD card
------------------------------

On your host, copy the file `sdcard.img` onto a microSD card with
`dd`:

    $ sudo dd if=output/images/sdcard.img of=/dev/mmcblk0 bs=512

You may need to adapt the name of the output device.


Boot from the microSD card
--------------------------

1. Power-down the board

2. Select the boot mode `101` to boot from the eMMC on the EVK board:

       BOOT SW3: OFF
       BOOT SW2: ON
       BOOT SW1: OFF

3. Then plug the microSD card into X23.

4. Connect to the UART connector X7 (located next to the Mini-USB plug)
   and run your serial communication program, Kermit, Minicom, etc. on
   the host. The default baudrate is 115200. You need to swap the pin 2
   and 3 of the serial cable.

5. Power-up the board.

6. The system will start, with the console on the UART.

7. The U-Boot environment is stored behind the `fip` partition in the
   SDcard/eMMC. Therefore you need to re-set the MAC address of the
   Ethernet interface once at the U-Boot prompt:

    => setenv ethaddr c0:e5:4e:bc:18:6b
    => saveenv

8. You can login into `root` without password.

9. The Linux device-tree used at boot is defined in `extlinux.conf`:

       # cat /boot/extlinux/extlinux.conf
       label stm32mp157a-msmp1evk-buildroot
         kernel /boot/zImage
         devicetree /boot/stm32mp157a-msmp1evk.dtb
       #  devicetree /boot/stm32mp157a-msmp1evk-rgb-panel.dtb
         append root=/dev/mmcblk0p4 rootwait

   If you have an RGP panel attached, please modify that file
   using `devicetree /boot/stm32mp157a-msmp1evk-rgb-panel.dtb`.


Create a bootable eMMC
----------------------

This is a bit more tricky, as the Arm Trusted Firmware image has to be
copied into the first boot section of the eMMC. To do so, we boot from
the microSD card into Linux as described above. Then we copy the
following files from the `images` directory to the target, e.g. by using
`scp` on the host:

    $ scp tf-a-stm32mp157a-msmp1evk.stm32 sdcard.img root@192.168.0.13:/tmp/

You may need to configure an IP address for the network interface first,
either using DHCP request:

    $ udhcpc -i eth0

or assigning a static IP adress:

    $ ifconfig eth0 192.168.0.13

Furthermore you may need to set a password for root with `# passwd` to
get `scp` to work.

Finally we write the images to `mmc1` on the target with:

    # dd if=/tmp/sdcard.img of=/dev/mmcblk1 bs=512
    # sync

    # echo 0 > /sys/block/mmcblk1boot0/force_ro
    # dd if=/tmp/tf-a-stm32mp157a-msmp1evk.stm32 of=/dev/mmcblk1boot0
    # sync
    # echo 1 > /sys/block/mmcblk1boot0/force_ro

There are various other methods to update the firmware in the eMMC. e.g.
in U-Boot by using `=> ums 0 mmc 1` or `=> mmc write ...`.


Boot from the eMMC
------------------

1. Power-down the board

2. Select the boot mode `010` to boot from the eMMC on the EVK board:

       BOOT SW3: ON
       BOOT SW2: OFF
       BOOT SW1: ON

3. Then follow the instructions listed above for "Boot from the
   microSD card" starting at item 4.


Create a bootable SPI-NOR flash
-------------------------------

The boot-loader (Arm-Trusted-Firmware + U-Boot) can also be installed
to and booted from the SPI-NOR flash:

- Update from Linux:

  Copy the following files from the `images` directory to the target, e.g.
  by using `scp` on the host:

      $ scp tf-a-stm32mp157a-msmp1evk.stm32 fip.bin spi-nor.img root@192.168.0.13:/tmp/

  Then write these on the target to the SPI-NOR flash:

      # flashcp /tmp/tf-a-stm32mp157a-msmp1evk.stm32 /dev/mtd0
      # flashcp /tmp/tf-a-stm32mp157a-msmp1evk.stm32 /dev/mtd1
      # flashcp /tmp/fip.bin /dev/mtd2

  or if you booted from the SDcard/eMMC

      # flashcp /tmp/spi-nor.img /dev/mtd0

- Update from U-Boot:

      STM32MP> tftp ${loadaddr} msmp1evk/spi-nor.img
      STM32MP> sf probe
      STM32MP> sf erase 0 +${filesize}
      STM32MP> sf write ${loadaddr} 0 ${filesize}


Boot from the SPI-NOR
---------------------

1. Power-down the board

2. Select the boot mode `001` to boot from the SPI-NOR of the EVK board:

       BOOT SW3: ON
       BOOT SW2: ON
       BOOT SW1: OFF

3. Then follow the instructions listed above for "Boot from the
   microSD card" starting at item 4.


[1]: https://www.aries-embedded.com/system-on-module/cpu/stmp157-stmicro-cortexa7-msmp1-osm-ethernet-can
[2]: https://www.aries-embedded.com/evaluation-kit/cpu/stmp157-stmicro-cortexa7-msmp1-osm-ethernet-can-msmp1evk
[3]: ../../README.md
