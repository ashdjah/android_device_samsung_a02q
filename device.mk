#
# Copyright (C) 2020 The Android Open Source Project
# SPDX-License-Identifier: Apache-2.0
#

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# fastbootd
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.0-impl-mock \
    fastbootd

# Touch firmware — Chipone TDDI (SM-A025F verified)
# Copied from /vendor/firmware/chipone-tddi.bin on running device
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/vendor/firmware/chipone-tddi.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/chipone-tddi.bin

# Touch firmware — Himax variants (other regional A02s variants)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/vendor/firmware/Himax_6mask_firmware.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/Himax_6mask_firmware.bin \
    $(LOCAL_PATH)/recovery/root/vendor/firmware/Himax_6mask_mpfw.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/Himax_6mask_mpfw.bin \
    $(LOCAL_PATH)/recovery/root/vendor/firmware/Himax_7mask_firmware.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/Himax_7mask_firmware.bin \
    $(LOCAL_PATH)/recovery/root/vendor/firmware/Himax_7mask_mpfw.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/Himax_7mask_mpfw.bin
