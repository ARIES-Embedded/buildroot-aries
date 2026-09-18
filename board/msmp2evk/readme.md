ARIES Embedded module MSMP2 on Evaluation Kit MSMP2EVK
========================================================================

Introduction
------------

This README describes how to build and install the firmware for the
ARIES Embedded System on Module (SoM) [MSMP2][1] and the Evaluation Kit
(EVK) MSMP2EVK.

Build
-----

How to build the BSP images is described in the [README.md][3] file in the
top directory of this repository.

Currently, the folloiwng hardware options and configs are supported:
    
    MSMP255D-BBA: STM32MP255D, STPMIC25B, 1 GB LPDDR4
                  stm32mp255d-msmp2evk_defconfig
                  stm32mp255d-msmp2evk-qt5_defconfig
    

SPI-NOR and SDcard/eMMC Layout
------------------------------

The layout is defined by `genimage.cfg`. The SPI-NOR is partitioned
as show below:

      Offset   Size  Image
    0x000000   256K  fsbl1
    0x040000   256K  fsbl2
    0x080000     4M  fip1
    0x480000     4M  fip2
    0x900000    64K  u-boot-env1
    0x940000    64K  u-boot-env2
    0x980000   6.5M  user-defined

And for the eMMC the following partitions are created:

    Number  Start (sector)    End (sector)  Size Name
         1             512            8703 4096K fip
         2            8704            8735 16384 u-boot-env
         3            8736          213535  100M rootfs

Images
------

The following files are generated in the `images` sub-directory:

- For partition "fsbl1" and "fsbl2":

      tf-a-stm32mp255d-msmp2evk.stm32  # Arm Trusted Firmware image

- For partition "fip":

      fip.img                          # FIP image

- For Partition "rootfs":

      rootfs.ext4                      # Root filesystem EXT4 image

- Linux devide-tree file:

      stm32mp255d-msmp2evk.dtb         # Device Tree Binary

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

NOTE: Booting from the microSD is not yet supported!

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
       label stm32mp255d-msmp2evk-buildroot
         kernel /boot/zImage
         devicetree /boot/stm32mp255d-msmp2evk.dtb
       #  devicetree /boot/stm32mp255d-msmp2evk-rgb-panel.dtb
         append root=/dev/mmcblk0p4 rootwait

   If you have an RGP panel attached, please modify that file
   using `devicetree /boot/stm32mp255d-msmp2evk-rgb-panel.dtb`.


Create a bootable eMMC
----------------------


This is a bit more tricky, as the Arm Trusted Firmware image has to be
copied into the first boot section of the eMMC. To do so, we boot from
the microSD card into Linux as described above. Then we copy the
following files from the `images` directory to the target, e.g. by using
`scp` on the host:

    $ scp tf-a-stm32mp255d-msmp2evk.stm32 sdcard.img root@192.168.0.13:/tmp/

You may need to configure an IP address for the network interface first,
either using DHCP request:

    $ udhcpc -i eth0

or assigning a static IP adress:

    $ ifconfig eth0 192.168.0.13

Furthermore you may need to set a password for root with `# passwd` to
get `scp` to work.

Finally we write the images to `mmc1` on the target and enable boot
fro the eMMC with:

    # dd if=/tmp/sdcard.img of=/dev/mmcblk1 bs=512
    # sync

    # echo 0 > /sys/block/mmcblk1boot0/force_ro
    # dd if=/boot/tf-a-stm32mp255d-msmp2evk.stm32 of=/dev/mmcblk1boot0 bs=512 && sync
    # sync
    # echo 0 > /sys/block/mmcblk1boot1/force_ro
    # dd if=/boot/tf-a-stm32mp255d-msmp2evk.stm32 of=/dev/mmcblk1boot1 bs=512 && sync
    # echo 0 > /sys/block/mmcblk1boot0/force_ro
    # sync

    # mmc bootbus set single_backward x1 x1 /dev/mmcblk1
    # mmc bootpart enable 1 1 /dev/mmcblk1

There are various other methods to update the firmware in the eMMC. e.g.
in U-Boot by using `=> ums 0 mmc 1` or `=> mmc write ...`.


Boot from the eMMC
------------------

NOTE: Currently only this boot mode is supported

1. Power-down the board

2. Select the boot mode `010` to boot from the eMMC on the EVK board:

       BOOT SW3: ON
       BOOT SW2: OFF
       BOOT SW1: ON

3. Then follow the instructions listed above for "Boot from the
   microSD card" starting at item 4.


Create a bootable SPI-NOR flash
-------------------------------

Not yet supported


Boot from the SPI-NOR
---------------------

Not yet supported


Boot from USB-OTG
-----------------

For board bring-up or debugging purposes is is handy to load and start
the bootloader via USB-OTG by using the STM32CubeProgrammer [4] on the
host.

For that purpose, you have to add `STM32MP_USB_PROGRAMMER=1`to the
Buildroot config `BR2_TARGET_ARM_TRUSTED_FIRMWARE_ADDITIONAL_VARIABLES`
manually. But with that config, Linux does not boot any more. ST is
aware of that limitation and want to fix it sooner than later.

For your convenience, there are pre-built bootloader images with the
suffix `_usb` and a flash loader script avaliable in the `images`
directory:

        - tf-a-stm32mp255d-msmp2evk_usb.stm32
        - fip-stm32mp255d-msmp2evk_usb.bin
        - fip-ddr-stm32mp255d-msmp2evk_usb.bin
        - flash.tsv

1. Power-down the board

2. Select the boot mode `111` to boot from USB-OTG of the EVK board:

       BOOT SW3: OFF
       BOOT SW2: OFF
       BOOT SW1: OFF

3. Connect the Debug-Console and the USB-OTG to your host.

4. Power-on the board and execute the following command on your host:

        $ cat images/flash.tsv 
        #opt    Id      Name            Type            Device  Offset          Binary
        -       0x01    fsbl_boot       Binary          none    0x0             tf-a-stm32mp255d-msmp2evk_usb.stm32
        -       0x02    fip_ddr         Binary          none    0x0             fip-ddr-stm32mp255d-msmp2evk_usb.bin
        -       0x03    fip_boot        Binary          none    0x0             fip-stm32mp255d-msmp2evk_usb.bin
        P       0x04    fsbl_boot1      Binary          mmc1    boot1           tf-a-stm32mp255d-msmp2evk.stm32
        P       0x05    fsbl_boot2      Binary          mmc1    boot2           tf-a-stm32mp255d-msmp2evk.stm32
        P       0x10    sdcard          RawImage        mmc1    0x0             sdcard.img

	$ <path>/STM32_Programmer_CLI -c port=USB1 -w flash.tsv

You should see the system booting on the Debug-Console. Then the primary
bootloader image will be written to the first and second boot partition
of the eMMC (mmc1) and finally `sdcard.img`. The change the boot switches
to boto from the eMMC.

5. Then follow the instructions listed above for "Boot from the
   microSD card" starting at item 4.


[1]: https://www.aries-embedded.com/system-on-module/cpu/stmp255-stmicro-cortexa35-msmp2-osm-ethernet-can-ai
[3]: ../../README.md
[4]: https://www.st.com/en/development-tools/stm32cubeprog.html
