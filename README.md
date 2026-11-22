# android_device_samsung_a02q

TWRP Device Tree for Samsung Galaxy A02s (SM-A025F / SM-A025F/DS) — Android 12

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build TWRP](https://github.com/ashdjah/android_device_samsung_a02q/actions/workflows/twrp-build.yml/badge.svg)](https://github.com/ashdjah/android_device_samsung_a02q/actions/workflows/twrp-build.yml)

---

## ⚠️ Important Warning — Read Before Flashing

**Use at your own risk.** CI build success does **not** guarantee that recovery will boot on every unit, that all panel variants will work, that decryption will function, or that your data will be safe.

**20261122d:** User reported real-hardware test on SM-A025F with touch working. Other features/hardware variants still need broader verification.

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
| CI Build | ✅ Passing | GitHub Actions workflow on `main` |
| Boot to TWRP | ⚠️ Reported working | User-reported on 20261122d; broader verification needed |
| Touch (ICNL9911C, hwid 991110) | ✅ Reported working | 20261122d force-loads `chipone-tddi.bin` via CTS `update_from_file` |
| Touch (other panel variants) | ❌ Untested | See issue #4 for variants/evidence |
| Brightness | ❌ Untested | Path verified from ADB |
| USB/ADB in recovery | ⚠️ Reported working | User-reported via Bugjaeger/adb; broader verification needed |
| Boot-loop failsafe / autoreboot | ⚠️ Implemented, limited verification | 45s autoreboot, 3-attempt/180s failsafe, BCB cleanup |
| Decryption / FBE | ⚠️ Limited | Run `multidisabler` if needed; understand data-at-rest risks |
| MTP | ❌ Untested | May require kernel changes |

---

## 📦 Prebuilt Artifacts (Required)

Before building, place the following files in `prebuilt/` (see [`prebuilt/README.md`](prebuilt/README.md)):

| File | Source | Required |
|------|--------|----------|
| `kernel` | Ragekill3377/a02q_twrp_tree_omni (main) | Yes |
| `dtb.img` | Ragekill3377/a02q_twrp_tree_omni (main) | Yes |
| `dtbo.img` | Ragekill3377/a02q_twrp_tree_omni (main) | Yes |
| `mkbootimg` | Ragekill3377/a02q_twrp_tree_omni (main) | Yes |

**Direct source:** https://github.com/Ragekill3377/a02q_twrp_tree_omni/tree/main/prebuilt

> ⚠️ Without these prebuilt artifacts, `make recoveryimage` will fail. The workflow verifies their presence before building. Compute SHA-256 checksums after downloading to verify integrity.

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

### Latest Release

Use the latest release unless you have a specific reason to test an older one. Older releases are kept for testing/changing release code and are marked **not recommended**.

- **Recommended:** [twrp-12.1-a02q-20261122d](https://github.com/ashdjah/android_device_samsung_a02q/releases/tag/twrp-12.1-a02q-20261122d)
- Older builds: see [Releases](https://github.com/ashdjah/android_device_samsung_a02q/releases) (marked sıkıntılı/not recommended)
- Untested EDL recovery package: [edl-a02q-recovery-untested-20261122](https://github.com/ashdjah/android_device_samsung_a02q/releases/tag/edl-a02q-recovery-untested-20261122)

### CI Build & Artifact Access

GitHub Actions workflow is at [`.github/workflows/twrp-build.yml`](.github/workflows/twrp-build.yml). It runs on `workflow_dispatch`, `pull_request`, and `push` to `main`.

```bash
gh workflow run twrp-build.yml --repo ashdjah/android_device_samsung_a02q
gh run list --repo ashdjah/android_device_samsung_a02q --workflow twrp-build.yml
gh run download <RUN_ID> --repo ashdjah/android_device_samsung_a02q --name TWRP-SM-A025F-recovery-image
```

---

## 💾 Flashing Instructions (Samsung SM-A025F/DS — Odin Only)

Samsung SM-A025F/DS uses **Download Mode + Odin**, not fastboot.

### Prerequisites

- Unlocked bootloader
- Odin (Windows) or Heimdall
- Stock firmware backup (BL, AP, CP, CSC)
- `vbmeta` backup if you modify AVB

### Flash via Odin

1. Download `recovery.tar.md5` from the [latest release](https://github.com/ashdjah/android_device_samsung_a02q/releases/tag/twrp-12.1-a02q-20261122d).
2. Boot device into Download Mode.
3. Open Odin, **uncheck Auto Reboot**.
4. Load `recovery.tar.md5` into **AP**.
5. Click **Start**.
6. After PASS, boot directly to Recovery (do not boot system first) to avoid stock recovery restoration.

### Flash via Heimdall

```bash
heimdall flash --RECOVERY recovery.img --no-reboot
```

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
| **Touch not working (ICNL9911C)** | CTS driver did not load firmware at boot | Fixed in 20261122d by `touch-fw.sh` force-loading `cts_firmware/update_from_file`. Manual temp test: `echo /vendor/firmware/chipone-tddi.bin > /sys/devices/platform/soc/78b7000.spi/spi_master/spi3/spi3.3/cts_firmware/update_from_file` |
| **Touch not working (other panel)** | Different controller/firmware | Collect `dmesg`/panel cmdline and report in #4 with evidence |
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

## 🙏 Credits

This tree builds on other people's work:

- **[Team Win Recovery Project (TWRP)](https://github.com/TeamWin)** — recovery sources
- **[minimal-manifest-twrp](https://github.com/minimal-manifest-twrp)** — manifest `platform_manifest_twrp_aosp`, branch `twrp-12.1`
- **AOSP / LineageOS** — base source tree
- **[@Ragekill3377](https://github.com/Ragekill3377/a02q_twrp_tree_omni)** — `prebuilt/kernel`, `prebuilt/dtb.img`, `prebuilt/dtbo.img` and `prebuilt/mkbootimg`
- **[@ashdjah](https://github.com/ashdjah)** — device tree and CI
- **openhands-agent** — build and CI fixes

Prebuilt binaries keep the license of their original source; see
[`prebuilt/README.md`](prebuilt/README.md).

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
