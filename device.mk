LOCAL_PATH := $(call my-dir)

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

# Firmware blobs are copied via find-copy-subdir-files in twrp_a02q.mk
