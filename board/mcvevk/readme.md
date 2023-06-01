ARIES Embedded MCV Evaluation Kit or Platform (EVK and EVP)
========================================================================

Introduction
------------

This README describes how to build the firmware for the ARIES Embedded
System on Module (SoM) [MCV][1] on the Evaluation Kit (EVK) and Platform
(EVP) [MCVEVP][2].


Build
-----

How to build the BSP images is described in the [README.md][3] file in the
top directory of this repository.


Images
------

Following files are generated in the `images` sub-directory:

- For U-Boot environment

      uboot-env.bin         # U-Boot environment (mmc offset 0x004400)

- For Partition 1:

      u-boot-spl.bin.crc    # Preloader          (mmc offset 0x100000)
      u-boot.img            # U-Boot             (mmc offset 0x140000)
      uboot.img             # Preloader + U-Boot (mmc offset 0x100000)

- For Partition 2:

      boot.vfat             # Boot partition: zImage + DTB blob

- For Partition 3:

      rootfs.ext4	    # Root filesystem EXT4 image

- For NFS:

      rootfs.tar.bz2        # Root filesystem archive
      socfpga_cyclone5_mcvevk.dtb # DTB blob
      zImage                # Linux kernel image

- Full MMC image:

      mmc.img               # overall MMC image  (mmc offset 0x000000)


MMC layout
----------

The MMC layout is defined by `genimage.cfg` and creates the following
partitions:

    Part  Start Sector    Num Sectors     UUID            Type
      1   2048            2048            00000000-01     a2
      2   4096            16384           00000000-02     0c Boot
      3   20480           1024000         00000000-03     83


Creating a bootable eMMC device
-------------------------------

The `mmc.img` can be written to the eMMC with U-Boot:

    => setenv update_file mmc.img
    => setenv update_mmc_offset 0
    => run update_mmc

If these U-Boot commands are not yet available, you can use:

    => tftp 1000000 mcvevk/mmc.img
    => setexpr sectors ${filesize} / 0x200
    => mmc write 1000000 0 $sectors

This will also write a new U-Boot environment. The old settings will
be lost. Therefore, after a reset (power-cycle), you need to reset
the Ethernet MAC address (which is printed on the label of the MCV
module), at least:

    => setenv ethaddr xx:xx:xx:xx:xx:xx
    => saveenv

Similarly, you can also write specific images to it's foreseen loaction.

With Linux, you can use the `dd` command to updated the MMC, e.g. to
update the preloader at offset 0x0 on partition 2:

    # dd if=/tmp/u-boot-spl.bin.crc of=/dev/mmcblk0p1 bs=4

Use `scp` to copy `u-boot-spl.bin.crc` from the host to the target.

Note: with Linux you can *not* update the root filesystem image while
it's in use.


Booting
-------

To boot from the MMC simply type (default after reset):

    => boot

To boot via network and mount the root filesystem with NFS:

    => setenv ipaddr 192.168.0.10
    => setenv serverip 192.168.0.254
    => setenv rootpath /tftpboot/mcvevk/rootfs
    => run net_nfs


System Recovery
---------------

If the eMMC is empty or the system does not boot any longer, you can use
the MCV recovery software and the USB Blaster device to install a MMC
image. Please contact Aries Embedded for further instructions.

[1]: https://www.aries-embedded.com/system-on-module/fpga/cyclone-v-intel-fpga-mcv-som-hps-altera-soc-pcie-transceiver
[2]: https://www.aries-embedded.com/evaluation-kit/fpga/cyclone-v-intel-fpga-mcvevp-hsmc-pmod
[3]: ../../README.md
