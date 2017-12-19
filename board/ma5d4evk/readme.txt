ARIES Embedded MA5D4 Evaluation Kit (MA5D4EVK)
===========================================================

Introduction
------------

More information about the Aries Embedded MA5D4 System on Module (SoM)
and EVK can be found at:

  - http://www.aries-embedded.de/?q=MA5D4
  - http://www.aries-embedded.de/?q=MA5D4EVK

Build
-----

How to build the BSP images is described in the README.md file in the
top directory of this repository.

Images
------

The following files are generated in the "images" sub-directory:

  - uboot-env.bin         # U-Boot environment (mmc offset 0x000200)

  For Partition 1:
  - boot.vfat             # Boot partition: bootloader + zImage + DTBs

  For Partition 2: 
  - rootfs.ext4           # Root filesystem EXT4 image

  For SPI NOR Flash:
  - boot.bin              # U-Boot SPL (preloader)
  - u-boot.img            # U-Boot

  For NFS:
  - rootfs.tar.bz2        # Root filesystem archive
  - at91-sama5d4_ma5d4sfevk.dtb   # DTB blob for MA5D4 with SPI NOR
  - at91-sama5d4_ma5d4emmcevk.dtb # DTB blob for MA5D4 without SPI NOR
  - zImage                # Linux kernel image

  Full MMC image:
  - mmc.img               # overall MMC image  (mmc offset 0x000000)

MMC layout
----------

The MMC layout is defined by "genimage.cfg" and creates the following
partitions:

  Part  Start Sector    Num Sectors     UUID            Type
    1   2048            32768           00000000-01     0c Boot
    2   34816           1048576         00000000-02     83

Creating a bootable eMMC device
-------------------------------

The "mmc.img" can be written to the eMMC with U-Boot:

  => tftp 20800000 ma5d4/mmc.img
  => setexpr sectors ${filesize} / 0x200
  => mmc write 20800000 0 $sectors 

This will also write a new U-Boot environment. The old settings will
be lost. Therefore, after a reset (power-cycle), you need to reset
the Ethernet MAC address (which is printed on the label of the MA5D4
module), at least:

  => setenv ethaddr xx:xx:xx:xx:xx:xx
  => saveenv

Similarly, you can also write specific images to it's foreseen loaction.

If the image is too big, it's also possible to write it with DFU.
Connect the MA5D4EVK with the host using a Mini-USB to USB-A cable and
type on the target at the U-Boot prompt:

  # dcu 0 mmc 0
  ...

Then send the "mmc.img" file on the host with:

  $ sudo dfu-util -D /tftpboot/ma5d4evk/mmc.img

With Linux, you can use the "dd" command to updated the MMC, e.g. to
update the boot partition 1:

  # dd if=/tmp/boot.vfat of=/dev/mmcblk1p1 bs=512

Use "scp" to copy "boot.vfat" from the host to the target.

Note: with Linux you can *not* update the root filesystem image while
it's in use.

Booting
-------

To boot from the MMC simply type (default after reset):

  => boot

To boot via network and mount the root filesystem with NFS:

  => setenv ipaddr 192.168.0.10
  => setenv serverip 192.168.0.254
  => setenv rootpath /tftpboot/ma5d4/rootfs
  => run net_nfs

Graphics
--------

You can build a BSP including QT5 and Tslib:

  $ cd $WORK_DIR/ma5d4evk
  $ make ma5d4evk_qt5_defconfig
  $ make

Then install the image(s) as described above and boot the system. To
run a QT5 example program, e.g. "standarddialogs", type:

  # ts_calibrate
  # export QT_QPA_FB_TSLIB=1
  # export TSLIB_TSDEVICE=/dev/input/event0
  # cd /usr/lib/qt/examples/widgets/dialogs/standarddialogs
  # ./standarddialogs
