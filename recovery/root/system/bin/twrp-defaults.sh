#!/system/bin/sh
#
# twrp-defaults.sh - dokunmatik olu cihaz icin TWRP varsayilanlari
#
# Swipe-to-allow-modifications ve ekran kilidi gibi dokunmatik gerektiren
# engelleri onceden kapatir. /data sifreli olabilir; mumkun olan her yere
# yazariz. Kalici olmayan /tmp degil, kalici ayar dosyalari hedeflenir.

LOG=/tmp/twrp-defaults.log
log() { echo "[twrp-defaults] $*" >> "$LOG" 2>/dev/null; }

write_settings() {
    f="$1"
    dir=$(dirname "$f")
    mkdir -p "$dir" 2>/dev/null || return 1
    # Var olan dosyayi koru, sadece eksik anahtarlari ekle.
    if [ -f "$f" ]; then
        grep -q '^tw_never_show_system_ro_page=' "$f" 2>/dev/null || echo 'tw_never_show_system_ro_page=1' >> "$f"
        grep -q '^tw_mount_system_ro=' "$f" 2>/dev/null || echo 'tw_mount_system_ro=0' >> "$f"
        grep -q '^tw_no_screen_timeout=' "$f" 2>/dev/null || echo 'tw_no_screen_timeout=1' >> "$f"
        grep -q '^tw_screen_timeout_secs=' "$f" 2>/dev/null || echo 'tw_screen_timeout_secs=0' >> "$f"
        log "guncellendi: $f"
    else
        cat > "$f" <<'CFG'
tw_never_show_system_ro_page=1
tw_mount_system_ro=0
tw_no_screen_timeout=1
tw_screen_timeout_secs=0
CFG
        log "olusturuldu: $f"
    fi
    chmod 644 "$f" 2>/dev/null
    return 0
}

log "basladi"

# /data acik olabilir (decrypt edilmis) veya degil. Deniyoruz.
for base in /data /cache /persist /metadata /sdcard /internal_sd; do
    [ -d "$base" ] || continue
    write_settings "$base/.twrps"
done

# TWRP bazen TWRP klasoru altina da bakar
for base in /sdcard/TWRP /data/media/0/TWRP /cache/TWRP; do
    [ -d "$(dirname "$base")" ] || continue
    write_settings "$base/.twrps"
done

sync
log "bitti"
