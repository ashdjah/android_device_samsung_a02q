#
# Copyright (C) 2020 The Android Open Source Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit some common TWRP stuff
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit telephony packages
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit language packages
$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)

# Inherit device configuration
$(call inherit-product, device/samsung/a02q/device.mk)

# Charger
PRODUCT_PACKAGES += \
    charger_res_images

PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,device/samsung/a02q/recovery/root,recovery/root)

## Device identifier
PRODUCT_NAME := twrp_a02q
PRODUCT_DEVICE := a02q
# Verified from device: ro.product.model = SM-A025F
PRODUCT_MODEL := SM-A025F
PRODUCT_BRAND := samsung
PRODUCT_MANUFACTURER := samsung
PRODUCT_GMS_CLIENTID_BASE := android-samsung
