# android_device_samsung_a02q

TWRP Device Tree for Samsung Galaxy A02s (SM-A025F / SM-A025F/DS) — Android 12

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build TWRP](https://github.com/ashdjah/android_device_samsung_a02q/actions/workflows/twrp-build.yml/badge.svg)](https://github.com/ashdjah/android_device_samsung_a02q/actions/workflows/twrp-build.yml)

---

## ⚠️ Important Warning — Read Before Flashing

**This device tree is UNTESTED.** It has **not** been booted on a physical SM-A025F/DS device. Build success does **not** guarantee that the recovery will boot, that touch will work, that decryption will function, or that your data will be safe.

Building, flashing, or using this project is entirely **at your own risk**. The maintainer and contributors are **not responsible** for:
- Device bricking (soft/hard brick)
- Data loss
- Warranty loss
- Any kind of damage

**Before flashing:**
1. Back up your stock firmware (BL, AP, CP, CSC)
2. Back up your `vbmeta` partition
3. Ensure your bootloader is unlocked

---

## 📱 Device Information

| Property | Value |
|----------|-------|
| Model | Samsung Galaxy A02s (SM-A025F / SM-A025F/DS) |
| Codename | `a02q` |
| Chipset | Qualcomm Snapdragon 450 (MSM8953) |
| GPU | Adreno 506 |
| Architecture | arm64 kernel + 32-bit userspace |
| Android Base | 12 (API 31) |
| TWRP Target | 3.7+ |
| Screen | 720×1600, 280 dpi |
| Touch Controller | ChipOne TDDI (SPI `spi3.3`) |
| Brightness Path | `/sys/devices/platform/soc/1a00000.qcom,mdss_mdp/1a00000.qcom,mdss_mdp:qcom,mdss_fb_primary/leds/lcd-backlight/brightness` |
| Super Partition | 4,848,615,424 bytes (~4.52 GB) |

---

## 📊 Test Status

| Feature | Status | Notes |
|---------|--------|-------|
| CI Build | Pending | GitHub Actions workflow |
| Boot to TWRP | ❌ Untested | No physical device available |
| Touch | ❌ Untested | `chipone-tddi.bin` firmware included |
| Brightness | ❌ Untested | Path verified from ADB |
| Decryption / FBE | ⚠️ Limited | Run `multidisabler` if needed; understand data-at-rest risks |
| MTP | ❌ Untested | May require kernel changes |

---

## 📦 Prebuilt Artifacts (Required)

Before building, place the following files in `prebuilt/` (see [`prebuilt/README.md`](prebuilt/README.md)):

| File | Source Revision | SHA-256 | Required |
|------|-----------------|---------|----------|
| `kernel` | Ragekill3377/a02q_twrp_tree_omni (main) | [compute locally] | Yes |
| `dtb.img` | Ragekill3377/a02q_twrp_tree_omni (main) | [compute locally] | Yes |
| `dtbo.img` | Ragekill3377/a02q_twrp_tree_omni (main) | [compute locally] | Yes |
| `mkbootimg` | Ragekill3377/a02q_twrp_tree_omni (main) | [compute locally] | Yes |

**Direct source:** https://github.com/Ragekill3377/a02q_twrp_tree_omni/tree/main/prebuilt

> ⚠️ Without these prebuilt artifacts, `make recoveryimage` will fail. The workflow verifies their presence before building. Compute the SHA-256 checksum of each file after downloading to verify integrity.

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

### CI Build & Artifact Access

GitHub Actions workflow is at [`.github/workflows/twrp-build.yml`](.github/workflows/twrp-build.yml). It runs on:

- `workflow_dispatch` (manual trigger)
- `pull_request`
- `push` to `main`

**Manual trigger:**
```bash
gh workflow run twrp-build.yml
```

**Download artifact:**
After a successful run, download `recovery.img` from the Actions page or via CLI:
```bash
gh run list --repo ashdjah/android_device_samsung_a02q --workflow twrp-build.yml
gh run download <RUN_ID> --name TWRP-SM-A025F-recovery-image
```

---

## 💾 Flashing Instructions (Samsung SM-A025F/DS — Odin Only)

Samsung SM-A025F/DS devices use **Download Mode + Odin**, not fastboot. Fastboot commands will **not** work on this device unless fastbootd is explicitly available in recovery (not guaranteed).

### Prerequisites

- Unlocked bootloader
- Odin (Windows) — [Download from official Samsung sources]
- Stock firmware backup (BL, AP, CP, CSC)
- `vbmeta_disabled.tar` if your device requires AVB disabled

### Flash via Odin

1. Boot device into Download Mode (Vol Down + Power + Vol Up)
2. Open Odin, **uncheck Auto Reboot**
3. Load `recovery.tar` into **AP** slot
4. Click **Start**
5. **Immediately boot to Recovery** (Vol Up + Power + USB) after flashing to prevent stock recovery restoration

---

## 🔙 Recovery Rollback

If TWRP fails to boot or causes a bootloop:

1. Boot to Download Mode
2. Flash stock firmware (BL, AP, CP, CSC) via Odin
3. Re-flash TWRP with Auto Reboot disabled
4. Boot to Recovery immediately

---

## 🐛 Troubleshooting

| Issue | Possible Cause | Solution |
|-------|---------------|----------|
| **Bootloop after flash** | Stock recovery restoration | Disable auto-reboot in Odin; boot to Recovery immediately after flashing. Rename `system/recovery-from-boot.p` to `.bak` |
| **Bootloop after flash** | vbmeta verification enabled | Flash `vbmeta_disabled.tar` in AP slot with flags=2 |
| **Touch not working** | Wrong touch controller firmware | Ensure `chipone-tddi.bin` is in `recovery/root/vendor/firmware/`. Try power-button lock/unlock |
| **No backlight control** | Wrong brightness path | Verify `/sys/class/leds/lcd-backlight/brightness` or `/sys/class/backlight/panel0-backlight/brightness` on your device |
| **MTP not working** | Kernel limitation | MTP may require kernel modification; not fixable in device tree alone |
| **Data not mounting/decrypting** | FBE encryption | Run `multidisabler` in TWRP Terminal, then Format Data. Understand data-at-rest risks |
| **Build fails: missing prebuilts** | `prebuilt/kernel`, `dtb.img`, `dtbo.img`, `mkbootimg` absent | Place files in `prebuilt/` (see `prebuilt/README.md`) |
| **Build fails: tar error** | GNU tar `-H` flag | Use `--format=ustar` instead of `-H ustar` (fixed in `bootimg.mk`) |
| **Build fails: envsetup nounset** | `set -u` with AOSP envsetup | Use `set +u` before sourcing `build/envsetup.sh` (fixed in workflow) |

### Reporting a Bug

When opening an issue, include:
- Device model and exact firmware version (e.g. SM-A025FXXUXXXX)
- Whether bootloader is unlocked
- Steps to reproduce
- Build output / logcat / dmesg if available
- What you expected vs. what happened

Use the bug report template under `.github/ISSUE_TEMPLATE/bug_report.md`.

---

## 🏷️ Device Variants

- **SM-A025F** — Snapdragon variant (this tree's target)
- **SM-A025F/DS** — Dual SIM variant (same chipset, compatible)
- **SM-A025G** — Not supported by this tree (different regional variant)

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for full guidelines. Summary:

1. **Fork** this repository
2. **Clone** your fork: `git clone https://github.com/<your-username>/android_device_samsung_a02q.git`
3. **Create a feature branch:** `git checkout -b feature/your-feature-name`
4. **Make changes** and test on a real device if possible
5. **Commit** with a clear message: `git commit -m "feat: describe your change"`
6. **Push** to your fork: `git push origin feature/your-feature-name`
7. **Open a Pull Request** against the `main` branch

### Code Style

- Follow existing AOSP/TWRP Makefile conventions.
- Keep comments in English where possible for broader collaboration.
- Do not commit secrets (keys, tokens, passwords).
- Prebuilt binaries (kernel, dtb, dtbo, mkbootimg, firmware blobs) should be documented in `prebuilt/README.md`.

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
