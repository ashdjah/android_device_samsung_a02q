# android_device_samsung_a02q

TWRP Device Tree for Samsung Galaxy A02s (SM-A025F / SM-A025F/DS) — Android 12

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build TWRP](https://github.com/ashdjah/android_device_samsung_a02q/actions/workflows/twrp-build.yml/badge.svg)](https://github.com/ashdjah/android_device_samsung_a02q/actions/workflows/twrp-build.yml)
[![Android 12](https://img.shields.io/badge/Android-12-green)](https://source.android.com/)
[![TWRP 3.7+](https://img.shields.io/badge/TWRP-3.7%2B-blue)](https://twrp.me/)

---

## 📱 Device Information

| Property | Value |
|----------|-------|
| Model | Samsung Galaxy A02s (SM-A025F / SM-A025F/DS) |
| Codename | `a02q` |
| Chipset | Qualcomm Snapdragon 450 (MSM8953) |
| GPU | Adreno 506 |
| Architecture | arm64 + arm (32-bit userspace) |
| Target OS | Android 12 (API 31) |
| TWRP Version | 3.7+ |
| Screen | 720×1600, 280 dpi |
| Touch Controller | ChipOne TDDI (SPI `spi3.3`) |
| Brightness Path | `/sys/devices/platform/soc/1a00000.qcom,mdss_mdp/1a00000.qcom,mdss_mdp:qcom,mdss_fb_primary/leds/lcd-backlight/brightness` |
| Super Partition | 4,848,615,424 bytes (~4.52 GB) |

---

## 🚀 Features

- ✅ Touch driver fix: `chipone-tddi` via SPI (removed invalid `hbtp_vm` blacklist)
- ✅ Platform version corrected to Android 12
- ✅ Brightness path verified from running device
- ✅ Super partition size verified from device (`mmcblk0p72`)
- ✅ Dynamic partitions group size updated
- ✅ Product model corrected to `SM-A025F`
- ✅ Pixel format `RGBX_8888` (correct for Samsung MDSS panel)
- ✅ Notch offsets removed (SM-A025F has no notch)
- ✅ Default brightness adjusted to 180
- ✅ OrangeFox-specific variables removed from `vendorsetup.sh`
- ✅ AVB disabled vbmeta support (`--flags 2`)
- ✅ GitHub Actions CI build (Ubuntu 22.04, JDK 11)

---

## 📦 Prebuilt Artifacts (Required)

Before building, place the following files in `prebuilt/` (see [`prebuilt/README.md`](prebuilt/README.md)):

| File | Description |
|------|-------------|
| `kernel` | Prebuilt kernel image |
| `dtb.img` | Device tree blob |
| `dtbo.img` | Recovery device tree blob overlay |
| `mkbootimg` | Boot image creation tool |

These were sourced from [Ragekill3377/a02q_twrp_tree_omni](https://github.com/Ragekill3377/a02q_twrp_tree_omni).

> ⚠️ Without these prebuilt artifacts, `make recoveryimage` will fail.

---

## 🛠️ Build Instructions

### Prerequisites

- Linux host (Ubuntu 22.04 recommended)
- ≥100 GB free disk space
- `repo`, Python 3, OpenJDK 11
- AOSP build dependencies (see workflow)
- Unlocked bootloader device for testing

### Manual Build

```bash
# Initialize TWRP 12.1 manifest
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1

# Sync sources
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8

# Clone this device tree
git clone https://github.com/ashdjah/android_device_samsung_a02q device/samsung/a02q

# Place prebuilt artifacts in device/samsung/a02q/prebuilt/ (see prebuilt/README.md)

# Build
export ALLOW_MISSING_DEPENDENCIES=true
. build/envsetup.sh
lunch twrp_a02q-eng
make recoveryimage -j$(nproc)

# Outputs:
# out/target/product/a02q/recovery.img
# out/target/product/a02q/recovery.tar (Odin-flashable)
```

### CI Build

GitHub Actions workflow is available at [`.github/workflows/twrp-build.yml`](.github/workflows/twrp-build.yml). It runs on:
- `workflow_dispatch` (manual)
- `pull_request`
- `push` to `main`

Trigger manually:
```bash
gh workflow run twrp-build.yml
```

---

## 💾 Flashing Instructions

### Prerequisites

- Unlocked bootloader
- Odin (Windows) or Heimdall/fastboot (Linux)
- Stock firmware backup (BL, AP, CP, CSC)
- `vbmeta_disabled.tar` if your device requires AVB disabled

### Flash via Odin

1. Boot device into Download Mode (Vol Down + Power + Vol Up)
2. Open Odin, uncheck **Auto Reboot**
3. Load `recovery.tar` into **AP** slot
4. Click **Start**
5. Immediately boot to Recovery (Vol Up + Power + USB) after flashing to prevent stock recovery restoration

### Flash via Fastboot / Heimdall

```bash
fastboot flash recovery recovery.img
fastboot flash vbmeta vbmeta_disabled.img  # if required
fastboot boot recovery.img
```

---

## ⚠️ Important Warning

**This device tree is UNTESTED.** Build success, hardware compatibility, and all functionality are provided **as-is** without warranty.

Building, testing, or using this project is entirely **at your own risk**. The developer and contributors are **not responsible** for:
- Device bricking (soft/hard brick)
- Data loss
- Warranty loss
- Any kind of damage

**Before flashing:**
1. Back up your stock firmware (BL, AP, CP, CSC)
2. Back up your `vbmeta` partition
3. Ensure your bootloader is unlocked

---

## 🐛 Known Limitations

- Encryption/FBE support is limited on this device; run `multidisabler` only if needed and understand data-at-rest risks.
- SELinux is not forced permissive in this tree; keep enforcing where possible.
- MTP may require kernel modifications.
- Touch may require power-button lock/unlock to reinitialize on some units.

---

## 🤝 Credits

- [ForForkSake/a02s](https://gitlab.com/ForForkSake/a02s) — Original OFRP tree
- [Ragekill3377/TWRP-SM-A025F-OS12](https://github.com/Ragekill3377/TWRP-SM-A025F-OS12) — TWRP build reference & prebuilt sources
- [SebaUbuntu](https://github.com/SebaUbuntu) — TWRP device tree generator
- [minimal-manifest-twrp/platform_manifest_twrp_aosp](https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp) — Manifest (twrp-12.1)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 🇹🇷 Türkçe Özet

Bu depo, **Samsung Galaxy A02s (SM-A025F)** cihazı için **Android 12 / TWRP 3.7+** hedefli bir **TWRP cihaz ağacıdır**.

### Özellikler
- Dokunmatik sürücüsü düzeltildi (`chipone-tddi`, SPI `spi3.3`)
- Platform sürümü Android 12'ye çıkarıldı
- Parlaklık yolu cihazdan doğrulandı
- Super bölüm boyutu cihazdan doğrulandı (`mmcblk0p72`)
- Dinamik bölüm grubu boyutu güncellendi
- Model `SM-A025F` olarak ayarlandı
- Piksel formatı `RGBX_8888` (Samsung MDSS panel için doğru)
- Notch offsets kaldırıldı (SM-A025F'de notch yok)
- Varsayılan parlaklık 180 olarak ayarlandı
- `vendorsetup.sh`'den OrangeFox özel değişkenleri kaldırıldı
- AVB devre dışı vbmeta desteği (`--flags 2`)
- GitHub Actions CI derleme desteği (Ubuntu 22.04, JDK 11)

### ⚠️ Önemli Uyarı
Bu cihaz ağacı **henüz test edilmemiştir**. Derleme, donanım uygunluğu ve tüm işlevsellik "olduğu gibi" sunulur, hiçbir garanti yoktur. Derleme, test veya kullanım tamamen kendi sorumluluğunuzdadır. Geliştirici ve katkıda bulunanlar, cihaz bozulması (soft/hard brick), veri kaybı, garanti kaybı veya her türlü hasardan sorumlu tutulamaz.

**Flashing işleminden önce:**
1. Stok firmware yedeğinizi alın (BL, AP, CP, CSC)
2. `vbmeta` bölümünüzün yedeğini alın
3. Bootloader'ınızın kilidinin açık olduğundan emin olun

---

## 🤖 AI-Assisted Development

Bu depodaki kodlar ve yapılandırma dosyaları yapay zeka (OpenCode) tarafından incelenmiş, analiz edilmiş ve iyileştirilmiştir. Tüm değişiklikler proje bakımcısı tarafından gözden geçirilmiştir ve üretime sunulmadan önce test edilmelidir.

The code and configuration files in this repository have been reviewed, analyzed, and improved using artificial intelligence (OpenCode). All changes have been reviewed by the repository maintainer and should be tested before production use.

---
