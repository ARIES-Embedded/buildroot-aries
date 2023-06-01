ARIES Embedded module MSMP1 on Evaluation Kit MSMP1EVK
========================================================================

Introduction
------------

This README describes how to build the firmware for the ARIES Embedded
System on Module (SoM) [MSMP1][1] and the Evaluation Kit (EVK)
[MSMP1EVK][2].


Build
-----

How to build the BSP images is described in the [README.md][3] file in the
top directory of this repository.


SDcard/eMMC Layout
------------------

The layout is defined by `genimage.cfg`. The following partitions are
created:

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


Create a bootable microSD card
------------------------------

On your host, copy the file `sdcard.img` onto a microSD card with
`dd`:

    $ sudo dd if=output/images/sdcard.img of=/dev/mmcblk0 bs=512

You may need to adapt the name of the output device.


### Boot from the microSD card:

- Select to boot mode `101` to boot from the microSD card:

      Boot[0]: Jumper on JP28 open
      Boot[1]: Jumper on Pin 7 and 9 of X16 closed
      Boot[2]: Jumper on Pin 6 and 8 of X16 open

- Connect to the UART connector X7 (located next to the Mini-USB plug)
  and run your serial communication program, Kermit, Minicom, etc. on
  the host. The default baudrate is 115200. You need to swap the pin 2
  and 3 of the serial cable.

- Then plug the microSD card into X23.

- Power-up the board.

- The system will start, with the console on the UART.

- You can login into `root` without password.


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

- Power-down the board

- Select the boot mode `010` to boot from the eMMC on the module:

      Boot[0]: Jumper on JP28 closed
      Boot[1]: Jumper on Pin 7 and 9 of X16 open
      Boot[2]: Jumper on Pin 6 and 8 of X16 closed

- Connect to the UART connector X7 (located next to the Mini-USB plug)
  and run your serial communication program, Kermit, Minicom, etc. on
  the host. The default baudrate is 115200. You need to swap the pin 2
  and 3 of the serial cable.

- Power-up the board.

- The system will start, with the console on the UART.

- You can login into `root` without password.

- Note that the U-Boot environment is stored in the `fip` partition
  of the boot device, microSD card or eMMC. Therefore you need to
  re-set the mac address of the Ethernet interface once at the U-Boot
  prompt:

    => setenv ethaddr c0:e5:4e:bc:18:6b
    => saveenv

[1]: https://www.aries-embedded.com/system-on-module/cpu/stmp157-stmicro-cortexa7-msmp1-osm-ethernet-can
[2]: https://www.aries-embedded.com/evaluation-kit/cpu/stmp157-stmicro-cortexa7-msmp1-osm-ethernet-can-msmp1evk
[3]: ../../README.md
