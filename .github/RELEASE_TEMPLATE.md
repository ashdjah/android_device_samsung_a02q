# TWRP for SM-A025F (a02q) / SM-A025F için TWRP — <tag> (<date>)

> **TR:** <tek cümlelik durum: donanımda doğrulandı / doğrulanmadı, ana değişiklik ve risk>
>
> **EN:** <one-line status: verified on hardware / unverified, main change and risk>

[Türkçe](#tr) | [English](#en)

## TR — Sürüm notları

**Donanım durumu:** <cihaz modeli, test eden kişi, tarih, doğrulanan ve doğrulanmayan özellikler>

**Değişiklikler:**

1. **<kısa başlık>** — <ne değişti, hangi dosya/servis, neden, doğrulama değerleri>
2. **<kısa başlık>** — <ne değişti, hangi dosya/servis, neden>

**Önceki sürümden gelenler:** <önceki build'den taşanan düzeltmeler>

**Donanım tuşları:** Vol+ yukarı, Vol− aşağı, Power seç. <doğrulandı / doğrulanmadı>

**Uyarı:** Custom recovery flaşlamak veri kaybı ve brick riski taşır. Önce stock firmware (BL/AP/CP/CSC) ve `vbmeta` yedeği alın, bootloader kilidini açın.

## EN — Release notes

**Hardware status:** <device model, who tested, date, verified and unverified features>

**Changes:**

1. **<short title>** — <what changed, which file/service, why, verification values>
2. **<short title>** — <what changed, which file/service, why>

**Carried over:** <fixes included from the previous build>

**Hardware keys:** Vol+ up, Vol− down, Power select. <verified / unverified>

**Warning:** flashing custom recovery can wipe data and brick the device. Back up stock firmware (BL/AP/CP/CSC) and `vbmeta`, and unlock the bootloader first.

## Ortak veri / Shared data

### İndirmeler / Downloads

| Dosya / File | Boyut / Size | Kullanım / Use |
|---|---:|---|
| `recovery.tar` | <bytes> | Odin — **AP** slotu / slot |
| `recovery.tar.md5` | <bytes> | `md5sum` çıktısı / manifest, flaş dosyası değil |
| `recovery.img` | <bytes> | `dd` / TWRP Install Image, **recovery** partition |

### Checksum'lar / Checksums

```text
SHA256
<hash>  recovery.img
<hash>  recovery.tar

MD5 (Odin)
<hash>  recovery.tar
```

### Kaynak / Source

- Repo: https://github.com/ashdjah/android_device_samsung_a02q
- Commit: `<sha>`
- CI: <actions run URL>
- İlgili issue / Related issues: <issue URLs>
