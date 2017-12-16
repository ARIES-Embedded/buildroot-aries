# buildroot-aries

Here you will find support for the ARIES Emedded System on Modules
(SoMs) and Evaluation Kits (EVKs) for [Buildroot][1]. We use an [external
buildroot tree][2] to maintain the ARIES Embedded specific parts.

The following EVKs are supported:

 * MCVEVK and [MCVEVP][3]

You can build an embedded Linux distribution with Buildroot as shown
below. The example is for the MCVEVP. For other EVKs just substitue the
machine name `mcvevk` with the name of your EVK:

        $ cd <work-dir>
        $ export WORK_DIR=`pwd`

We need to clone the ARIES Embedded external buildroot tree and the
official buildroot repository:

        $ git clone https://github.com/ARIES-Embedded/buildroot-aries.git

        $ git clone --branch 2017.11.x git://git.buildroot.net/buildroot.git

If the maintenance branch `2017.11.x` is not yet available, please use:

        $ git clone git://git.buildroot.net/buildroot.git
        $ cd buildroot
        $ git checkout -b aries-2017.11 2017.11

Then create a build directory for the default configuration:

        $ cd $WORK_DIR/buildroot
        $ make BR2_EXTERNAL=$WORK_DIR/buildroot-aries \
            O=$WORK_DIR/mcvevk aries_mcvevk_defconfig

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
[3]: board/mcvevk/readme.txt
