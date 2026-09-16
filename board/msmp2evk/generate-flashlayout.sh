#!/usr/bin/env bash

#
# atf_image extracts the ATF binary image from DTB_FILE_NAME that appears in
# BR2_TARGET_ARM_TRUSTED_FIRMWARE_ADDITIONAL_VARIABLES in ${BR_CONFIG},
# then prints the corresponding file name for the genimage
# configuration file
#
atf_image()
{
	local ATF_VARIABLES="$(sed -n 's/^BR2_TARGET_ARM_TRUSTED_FIRMWARE_ADDITIONAL_VARIABLES="\(.*\)"$/\1/p' ${BR2_CONFIG})"

	local DTB_NAME="$(sed -n 's/.*DTB_FILE_NAME=\([^ ]*\)/\1/p' <<< ${ATF_VARIABLES})"
	local STM_NAME="tf-a-$(cut -f1 -d'.' <<< ${DTB_NAME}).stm32"
	echo ${STM_NAME}
}

generate_flashlayout()
{
	local ATFBIN="$(atf_image)"
	if [ ! -e ${BINARIES_DIR}/${ATFBIN} ]; then
		echo "Can not find ATF binary ${ATFBIN}"
		exit 1
	fi
	local BOARD_PATH=$(dirname "${2}")
	local USB_FLASH_BINARIES_PATH="$(dirname $0)/usb_flash_binaries/"

        # Copy flash layout and necessary binary files
	case "${ATFBIN}" in
		*"stm32mp255d-msmp2evk"*)
			local FIP_USB_BIN="fip-stm32mp255d-msmp2evk_usb.bin"
			local FIP_DDR_USB_BIN="fip-ddr-stm32mp255d-msmp2evk_usb.bin"
			local ATF_USB_BIN="tf-a-stm32mp255d-msmp2evk_usb.stm32"
			local ATF_MMC_BIN="tf-a-stm32mp255d-msmp2evk.stm32"
			;;
	esac
	sed -e "s/%ATFUSBBIN%/${ATF_USB_BIN}/" -e "s/%FIPUSBBIN%/${FIP_USB_BIN}/" \
		-e "s/%FIPDDRUSBBIN%/${FIP_DDR_USB_BIN}/" -e "s/%ATFMMCBIN%/${ATF_MMC_BIN}/" \
		${BOARD_PATH}/flash.tsv > ${BINARIES_DIR}/flash.tsv

	cp -f ${USB_FLASH_BINARIES_PATH}${ATF_FLASH} ${USB_FLASH_BINARIES_PATH}${FIP_FLASH} ${BINARIES_DIR}
	if [ -n "${FIP_DDR_FLASH}" ]; then
		cp -f ${USB_FLASH_BINARIES_PATH}${FIP_DDR_FLASH} ${BINARIES_DIR}
	fi

	exit $?
}

generate_flashlayout $@
