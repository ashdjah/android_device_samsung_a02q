# TWRP Device Tree — Samsung Galaxy A02s (SM-A025F)

**Target OS**: Android 12 (API 31) **TWRP version**: 3.7+ **Chipset**: Qualcomm Snapdragon 450 (MSM8953)

## Changes from original OFRP tree (ForForkSake/a02s)

### 🔴 Critical fixes

| Fix | Detail |
| --- | --- |
| **Touch driver** | Removed `TW_INPUT_BLACKLIST := "hbtp_vm"` — `hbtp_vm` does not exist on SM-A025F. Touch controller is `chipone-tddi` via SPI (`spi3.3`). Added `chipone-tddi.bin` firmware to recovery ramdisk. |
| **Platform version** | Changed `PLATFORM_VERSION` from `11` → `12` (device runs Android 12) |

### 🟠 Important fixes

| Fix | Detail |
| --- | --- |
| **Brightness path** | Corrected to verified sysfs path from running device |
| **Super partition size** | Updated from `4324327424` → `4848615424` bytes (verified from `mmcblk0p72`) |
| **Dynamic partitions group size** | Updated accordingly: `4844421120` |

### 🟡 Minor fixes

| Fix | Detail |
| --- | --- |
| **Product model** | `SM-A025G` → `SM-A025F` |
| **Pixel format** | `BGRA_8888` → `RGBX_8888` (correct for Samsung MDSS) |
| **Notch offsets** | Removed — SM-A025F has no notch |
| **Default brightness** | `130` → `180` |
| **vendorsetup.sh** | Retains OrangeFox helper functions; unused for TWRP builds |

## Device info (verified via ADB)

```
Model:          SM-A025F
Platform:       MSM8953 (Snapdragon 450)
Touch:          chipone-tddi @ /dev/input/event2 (SPI spi3.3)
Screen:         720x1600, density 280
Brightness:     /sys/devices/platform/soc/1a00000.qcom,mdss_mdp/.../leds/lcd-backlight/brightness
Max brightness: 255
Super size:     4848615424 bytes (4.52 GB)
Android:        12 (SDK 31)
```

## Prerequisites

- Linux host with at least 100 GB free disk space
- `repo`, Python 3, OpenJDK 11
- AOSP build dependencies (see workflow)
- Unlocked bootloader device for flashing/testing

## Prebuilt artifacts (required)

Before building, place these files in `prebuilt/` (see `prebuilt/README.md`):

- `Image.gz`
- `dtb`
- `recoverydtbo`
- `mkbootimg`

## Build

```
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8

# Clone this tree
git clone https://github.com/ashdjah/android_device_samsung_a02q device/samsung/a02q

# Place prebuilt kernel artifacts (see prebuilt/README.md)
export ALLOW_MISSING_DEPENDENCIES=true
. build/envsetup.sh
lunch twrp_a02q-eng
make recoveryimage -j$(nproc)

# Outputs:
# out/target/product/a02q/recovery.img
# out/target/product/a02q/recovery.tar  (Odin-flashable)
```

CI build is available via `.github/workflows/twrp-build.yml` (manual dispatch and on PR/push).

## Flashing (high level)

- Flash `recovery.tar` via Odin in the AP slot (or `recovery.img` via fastboot/heimdall where supported).
- Flash a disabled-vbmeta image if required by your device/firmware.
- Disable auto-reboot in Odin and boot recovery immediately to avoid stock recovery restoration.

## Known limitations

- `TW_INCLUDE_CRYPTO` is enabled but encryption/FBE support on this device is limited; run `multidisabler` only if needed and understand data-at-rest risks.
- SELinux is not forced permissive in this tree; keep enforcing where possible.
- MTP may require kernel changes.
- Touch may need power-button lock/unlock to reinitialize on some units.

## Credits

- Original OFRP tree: [ForForkSake/a02s](https://gitlab.com/ForForkSake/a02s)
- TWRP build reference: [Ragekill3377](https://github.com/Ragekill3377/TWRP-SM-A025F-OS12)
- Device tree generated with SebaUbuntu's TWRP device tree generator
- Manifest: minimal-manifest-twrp/platform_manifest_twrp_aosp (twrp-12.1)
- Prebuilt kernel/dtb source: see prebuilt/README.md

## About

TWRP device tree for Samsung Galaxy A02s (SM-A025F/DS) - Android 12

### Resources

[Readme](#readme-ov-file)

[MIT license](#MIT-1-ov-file)

## ⚠️ Important Warning

This device tree is **untested**. Build, hardware compatibility, and karma-based workflow mean that building, testing, or using this project is entirely at your own risk. The developer and contributors of this repository are not responsible for device bricking (soft/hard brick), data loss, warranty loss, or any kind of damage. Before flashing, make sure to back up your stock firmware and `vbmeta`.
