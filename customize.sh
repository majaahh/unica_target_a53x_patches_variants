# Copyright (c) 2026 Majaahh
# SPDX-License-Identifier: GPL-3.0-or-later

ADD_TO_WORK_DIR "$MODPATH" "vendor_dlkm" "." 0 0 755 "u:object_r:vendor_file:s0"

for i in "odm" "vendor" "vendor_dlkm"; do
    PROP="$i/etc/build.prop"
    if [[ "$i" == "vendor" ]]; then
        PROP="$i/build.prop"
    fi

    {
        echo "# Added by target/a53x/patches/variants/customize.sh"
        echo "import /$i/etc/sku/\${ro.boot.em.model}.prop"
    } >> "$WORK_DIR/$PROP"

    unset PROP
done

# NXP NFC Support
LOG_STEP_IN "- Deleting SLSI NFC init"
DELETE_FROM_WORK_DIR "vendor" "etc/init/sec.android.hardware.nfc@1.2-service.rc"
LOG_STEP_OUT

LOG_STEP_IN "- Adding NXP NFC blobs"
ADD_TO_WORK_DIR "a53xdcm" "vendor" "bin/hw/nxp.android.hardware.nfc@1.2-service"
ADD_TO_WORK_DIR "a53xdcm" "vendor" "etc/libnfc-nxp.conf"
ADD_TO_WORK_DIR "a53xdcm" "vendor" "etc/nfc/libnfc-nxp_RF.conf"
ADD_TO_WORK_DIR "a53xdcm" "vendor" "firmware/nfc/libsn100u_fw.so"
ADD_TO_WORK_DIR "a53xdcm" "vendor" "lib64/nfc_nci_nxpsn.so"
LOG_STEP_OUT

LOG_STEP_IN "- Adding NXP eSE blobs"
ADD_TO_WORK_DIR "a53xdcm" "vendor" "etc/libese-nxp.conf"
ADD_TO_WORK_DIR "a53xdcm" "vendor" "lib64/ese_spi_nxp.so"
LOG_STEP_OUT

LOG_STEP_IN "- Setting up libnfc-nci configuration"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/libnfc-nci.conf" 0 0 644 "u:object_r:system_file:s0"
LOG "- Renaming /system/system/etc/libnfc-nci.conf to /system/system/etc/libnfc-nci-SLSI.conf"
EVAL "mv \"$WORK_DIR/system/system/etc/libnfc-nci.conf\" \"$WORK_DIR/system/system/etc/libnfc-nci-SLSI.conf\""
SET_METADATA "system" "system/etc/libnfc-nci-SLSI.conf" 0 0 644 "u:object_r:system_file:s0"

ADD_TO_WORK_DIR "a53xdcm" "system" "system/etc/libnfc-nci.conf"
LOG "- Renaming /system/system/etc/libnfc-nci.conf to /system/system/etc/libnfc-nci-NXP.conf"
EVAL "mv \"$WORK_DIR/system/system/etc/libnfc-nci.conf\" \"$WORK_DIR/system/system/etc/libnfc-nci-NXP.conf\""
SET_METADATA "system" "system/etc/libnfc-nci-NXP.conf" 0 0 644 "u:object_r:system_file:s0"
LOG_STEP_OUT

LOG "- Adding SELinux entries"
{
    echo "(allow init_31_0 tee_file (dir (mounton)))"
    echo "(allow priv_app_31_0 tee_file (dir (getattr)))"
    echo "(allow init_31_0 vendor_fw_file (file (mounton)))"
    echo "(allow priv_app_31_0 vendor_fw_file (file (getattr)))"
    echo "(allow init_31_0 vendor_npu_firmware_file (file (mounton)))"
    echo "(allow priv_app_31_0 vendor_npu_firmware_file (file (getattr)))"
} >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil" || return 1
