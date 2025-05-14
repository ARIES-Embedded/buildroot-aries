# buildroot-aries

Here you will find support for the ARIES Emedded System on Modules
(SoMs) and Evaluation Kits (EVKs) for [Buildroot][1]. We use an [external
buildroot tree][2] to maintain the ARIES Embedded specific parts.

The following EVKs are supported:

 * MCVEVK and [MCVEVP][3]
 * [MA5D4EVK][4]
 * [MSMP1EVK][5]

You can build an embedded Linux distribution with Buildroot as shown
below. The example is for the MCVEVP. For other EVKs just substitue the
board name `mcvevk` with the name of your EVK, `ma5d4evk` or `msmp1evk`.

        $ cd <work-dir>
        $ export WORK_DIR=`pwd`

We need to clone the ARIES Embedded external buildroot tree and the
official buildroot repository:

        $ git clone https://github.com/ARIES-Embedded/buildroot-aries.git

        $ git clone --branch 2023.02.x git://git.buildroot.net/buildroot.git

If the maintenance branch `2023.02.x` is not yet available, please use:

        $ git clone git://git.buildroot.net/buildroot.git
        $ cd buildroot
        $ git checkout -b aries-2023.02 2023.02

For the MSMP1EVK, you also need to apply some temporary patches for th ARM
Trusted Firmware and U-Boot boot loader:

        $ cd $WORK_DIR/buildroot
        $ git am $WORK_DIR/buildroot-aries/board/msmp1evk/buildroot-patches/*.patch

Then create a build directory for the default configuration:

        $ cd $WORK_DIR/buildroot
        $ make BR2_EXTERNAL=$WORK_DIR/buildroot-aries \
            O=$WORK_DIR/mcvevk mcvevk_defconfig

You can find the available defconfigs in `=WORK_DIR/buildroot-aries/configs/`.

And finally make the BSP for the MCVEVP:

        $ cd $WORK_DIR/mcvevk
        $ make

If you need an SDK for application development type:

        $ make sdk

The SDK is relocatable. You need to run the "relocate-sdk.sh" script
once after copying the SDK to the new location:

        $ cp -r $WORK_DIR/mcvevk/host /opt/sdk-mcvevk
        $ /opt/sdk-mcvevk/relocate-sdk.sh
        Relocating the buildroot SDK from ... to ...


[1]: https://buildroot.org
[2]: https://buildroot.org/downloads/manual/manual.html#outside-br-custom
[3]: board/mcvevk/readme.md
[4]: board/ma5d4evk/readme.txt
[5]: board/msmp1evk/readme.md
