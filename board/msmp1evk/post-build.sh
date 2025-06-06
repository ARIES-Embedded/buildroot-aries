#!/usr/bin/env bash

#
# board_name extracts the name of the board from DTB_FILE_NAME that appears
# in BR2_TARGET_ARM_TRUSTED_FIRMWARE_ADDITIONAL_VARIABLES in ${BR_CONFIG},
# then prints the corresponding name to be used in the genimage and
# extlinux configuration file
#
board_name()
{
	local ATF_VARIABLES="$(sed -n 's/^BR2_TARGET_ARM_TRUSTED_FIRMWARE_ADDITIONAL_VARIABLES="\([\/a-zA-Z0-9_=. \-]*\)"$/\1/p' ${BR2_CONFIG})"

	if grep -Eq "DTB_FILE_NAME=stm32mp157a-msmp1evk.dtb" <<< ${ATF_VARIABLES}; then
		echo "stm32mp157a-msmp1evk"
	elif grep -Eq "DTB_FILE_NAME=stm32mp157c-msmp1evk.dtb" <<< ${ATF_VARIABLES}; then
		echo "stm32mp157c-msmp1evk"
	fi
}

main()
{
	local BOARD_NAME="$(board_name)"
	local GENIMAGE_CFG="${BUILD_DIR}/genimage.cfg"
	local BOARD_PATH=${BR2_EXTERNAL_ARIES_PATH}/board/msmp1evk""

	mkdir -p "$TARGET_DIR/boot/extlinux/"
	sed -e "s/%BOARD_NAME%/${BOARD_NAME}/" \
		${BOARD_PATH}/extlinux.conf.template > "$TARGET_DIR/boot/extlinux/extlinux.conf"

	# Generate genimage configuration file to be used later by
	# via confguration options:
	# BR2_ROOTFS_POST_IMAGE_SCRIPT="support/scripts/genimage.sh"
	# BR2_ROOTFS_POST_SCRIPT_ARGS="-c $(BUILD_DIR)/genimage.cfg"
	sed -e "s/%BOARD_NAME%/${BOARD_NAME}/" \
		${BOARD_PATH}/genimage.cfg.template > ${GENIMAGE_CFG}

	exit $?
}

main $@
