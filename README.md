# TWRP Device Tree — Samsung Galaxy A02s (SM-A025F)

**Target OS**: Android 12 (API 31)
**TWRP version**: 3.7+
**Chipset**: Qualcomm Snapdragon 450 (MSM8953)

## Changes from original OFRP tree (ForForkSake/a02s)

### 🔴 Critical fixes

| Fix | Detail |
|-----|--------|
| **Touch driver** | Removed `TW_INPUT_BLACKLIST := "hbtp_vm"` — `hbtp_vm` does not exist on SM-A025F. Touch controller is `chipone-tddi` via SPI (`spi3.3`). Added `chipone-tddi.bin` firmware to recovery ramdisk. |
| **Platform version** | Changed `PLATFORM_VERSION` from `11` → `12` (device runs Android 12) |

### 🟠 Important fixes

| Fix | Detail |
|-----|--------|
| **Brightness path** | Corrected to verified sysfs path from running device |
| **Super partition size** | Updated from `4324327424` → `4848615424` bytes (verified from `mmcblk0p72`) |
| **Dynamic partitions group size** | Updated accordingly: `4844421120` |

### 🟡 Minor fixes

| Fix | Detail |
|-----|--------|
| **Product model** | `SM-A025G` → `SM-A025F` |
| **Pixel format** | `BGRA_8888` → `RGBX_8888` (correct for Samsung MDSS) |
| **Notch offsets** | Removed — SM-A025F has no notch |
| **Default brightness** | `130` → `180` |
| **vendorsetup.sh** | Removed OrangeFox-specific variables |

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

## Build

```bash
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8

# Clone this tree
git clone https://github.com/<your_username>/android_device_samsung_a02q device/samsung/a02q

. build/envsetup.sh
lunch twrp_a02q-eng
make recoveryimage -j$(nproc)
```

## Credits

- Original OFRP tree: [ForForkSake/a02s](https://gitlab.com/ForForkSake/a02s)
- Original TWRP build guide: [Ragekill3377](https://github.com/Ragekill3377/TWRP-SM-A025F-OS12)
