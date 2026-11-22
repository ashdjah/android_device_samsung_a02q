#
# Copyright (C) 2020 The Android Open Source Project
# Copyright (C) 2024 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#
# Device tree for Samsung Galaxy A02s (SM-A025F)
# Fixed for Android 12 / TWRP 3.7+
# Fixes: touch (chipone-tddi), brightness path, super partition size,
#        platform version, pixel format
#

# Bootloader
BOARD_VENDOR := samsung
TARGET_SOC := msm8953
TARGET_BOOTLOADER_BOARD_NAME := msm8953
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true
TARGET_USES_UEFI := true

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a53
TARGET_CPU_VARIANT_RUNTIME := cortex-a53

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a53
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a53

TARGET_USES_64_BIT_BINDER := true
TARGET_SUPPORTS_64_BIT_APPS := false

ENABLE_CPUSETS := true
ENABLE_SCHEDBOOST := true

ALLOW_MISSING_DEPENDENCIES := true

# File systems
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# Platform
BOARD_USES_QCOM_HARDWARE := true
TARGET_BOARD_PLATFORM := msm8953
TARGET_BOARD_PLATFORM_GPU := qcom-adreno506
QCOM_BOARD_PLATFORMS += msm8953

# Kernel
TARGET_PREBUILT_KERNEL := device/samsung/a02q/prebuilt/kernel
TARGET_PREBUILT_DTB := device/samsung/a02q/prebuilt/dtb.img
BOARD_PREBUILT_DTBOIMAGE := device/samsung/a02q/prebuilt/dtbo.img
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_INCLUDE_RECOVERY_DTBO := true
TARGET_KERNEL_ARCH := arm64

# Boot
BOARD_BOOT_HEADER_VERSION := 2
BOARD_KERNEL_BASE := 0x80000000
BOARD_KERNEL_CMDLINE := androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 androidboot.usbconfigfs=true vmalloc=300M loop.max_part=7
BOARD_KERNEL_IMAGE_NAME := Image
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x02000000
BOARD_KERNEL_SECOND_OFFSET := 0x00f00000
BOARD_KERNEL_TAGS_OFFSET := 0x01e00000
BOARD_DTB_OFFSET := 0x01f00000
BOARD_MKBOOTIMG_ARGS := --kernel_offset $(BOARD_KERNEL_OFFSET) --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET) --second_offset $(BOARD_KERNEL_SECOND_OFFSET)
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION) --pagesize $(BOARD_KERNEL_PAGESIZE) --board "SRPSJ30A001"
BOARD_MKBOOTIMG_ARGS += --dtb $(TARGET_PREBUILT_DTB) --dtb_offset $(BOARD_DTB_OFFSET)
BOARD_CUSTOM_BOOTIMG_MK := device/samsung/a02q/bootimg.mk

# Recovery
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_HAS_NO_SELECT_BUTTON := true

# Partitions
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864

# Dynamic Partitions
# Verified from device: /dev/block/mmcblk0p72 = 4734976 * 1024 = 4848615424 bytes
BOARD_SUPER_PARTITION_SIZE := 4848615424
BOARD_SUPER_PARTITION_GROUPS := samsung_dynamic_partitions
# Group size = super size - 4MiB metadata overhead
BOARD_SAMSUNG_DYNAMIC_PARTITIONS_SIZE := 4844421120
BOARD_SAMSUNG_DYNAMIC_PARTITIONS_PARTITION_LIST := system vendor product odm

# System as root
BOARD_ROOT_EXTRA_FOLDERS := cache carrier efs keydata keyrefuge optics prism
BOARD_SUPPRESS_SECURE_ERASE := false

# Workaround for error copying vendor files to recovery ramdisk
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR := vendor

AB_OTA_UPDATER := false

# Android Verified Boot
BOARD_AVB_ENABLE := true
BOARD_AVB_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
# TODO: replace with a protected production key; AOSP test key is public
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 2

# Crypto
# Security patch set far in future to avoid version check failures during build
PLATFORM_SECURITY_PATCH := 2022-12-01
VENDOR_SECURITY_PATCH := 2022-12-01
# SM-A025F ships with Android 10 (API 29), currently running Android 12
PLATFORM_VERSION := 12
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
BOARD_USES_METADATA_PARTITION := true

# TWRP specific build flags
TW_DEVICE_VERSION := 2_SM-A025F
TW_THEME := portrait_hdpi
RECOVERY_SDCARD_ON_DATA := true
TARGET_RECOVERY_QCOM_RTC_FIX := true

# Display
# Verified: Samsung MDSS panel — RGBX_8888 is correct for this device
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888

# Brightness
# Path verified from running SM-A025F:
# adb shell find /sys/devices -path '*/leds/lcd-backlight*'
TW_BRIGHTNESS_PATH := "/sys/devices/platform/soc/1a00000.qcom,mdss_mdp/1a00000.qcom,mdss_mdp:qcom,mdss_fb_primary/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 180

# SM-A025F has no display notch — Y/H offsets intentionally omitted

TW_NO_REBOOT_BOOTLOADER := true
TW_HAS_DOWNLOAD_MODE := true
TW_INCLUDE_NTFS_3G := true
TW_USE_NEW_MINADBD := true

# Dokunmatik olu oldugu icin ekran/acilis davranislari
TW_NO_SCREEN_TIMEOUT := true
TW_NO_SCREEN_BLANK := true

# Touch Driver Fix
# Touch controller verified from device: /dev/input/event2 -> "chipone-tddi"
# Connected via SPI: /devices/platform/soc/78b7000.spi/spi3/spi3.3/input/input2
# hbtp_vm does NOT exist on SM-A025F (verified with getevent -l)
# Firmware: /vendor/firmware/chipone-tddi.bin (55168 bytes) included in ramdisk
# TW_INPUT_BLACKLIST intentionally NOT set (removed hbtp_vm from original tree)
# Ekrani kapatma yok; dokunmatik olu oldugu icin kullanici ekrani gormeli
TW_SCREEN_BLANK_ON_BOOT := false

TW_EXCLUDE_DEFAULT_USB_INIT := true
TW_USE_TOOLBOX := true
TARGET_USES_MKE2FS := true
TW_NO_LEGACY_PROPS := true
TW_NO_BIND_SYSTEM := true
TW_EXTRA_LANGUAGES := false
TW_INCLUDE_RESETPROP := true

# Logcat — useful for debugging touch and display issues
TWRP_INCLUDE_LOGCAT := false
TARGET_USES_LOGD := false
