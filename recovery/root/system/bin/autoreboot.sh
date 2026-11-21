#!/system/bin/sh
#
# autoreboot.sh - TWRP guvenlik agi (SM-A025F / a02q)
#
# Amac: TWRP acildiktan sonra 17 saniye icinde hicbir girdi (dokunmatik,
# tus, fare) gelmezse cihazi sisteme yeniden baslatir. Dokunmatik surucu
# calismadiginda cihaz TWRP'de kilitli kalip boot dongusune giriyor;
# bu betik o donguyu kirar.
#
# KULLANIM:
#   /system/bin/autoreboot.sh           (init baslatir)
#   /system/bin/autoreboot.sh cancel    geri sayimi ve servisi oldurur
#
# Iptal (bu oturumda TAMAMEN durur, reboot'a kadar geri gelmez):
#   - adb shell touch /tmp/ready
#   - adb shell touch /tmp/-ready
#   - adb shell /system/bin/autoreboot.sh cancel
#   - Ekrana dokun / ses veya power tusuna bas / USB fareyi oynat
#   - /tmp/no-autoreboot veya /cache/.no-autoreboot
#   - /sys/class/udc/*/state = configured (PC veya Termux bagli)
#   - TWRP ayarlari degisirse (/data/.twrps)
#
# Log: /tmp/autoreboot.log  (ve /tmp/recovery.log)
#

LOG=/tmp/autoreboot.log
DELAY=17
HIT=/tmp/autoreboot.hit
STOP=/tmp/autoreboot.stop
PIDFILE=/tmp/autoreboot.pid

log() {
    echo "[autoreboot] $*" >> "$LOG" 2>/dev/null
    echo "[autoreboot] $*" >> /tmp/recovery.log 2>/dev/null
}

# --- Elle iptal: "autoreboot.sh cancel" -------------------------------------
case "$1" in
    cancel | stop | iptal)
        : > /tmp/ready 2>/dev/null
        log "manuel iptal istendi (adb/shell)"
        if [ -f "$PIDFILE" ]; then
            old=$(cat "$PIDFILE" 2>/dev/null)
            [ -n "$old" ] && kill "$old" 2>/dev/null
            log "calisan surec olduruldu (pid=$old)"
        fi
        echo "autoreboot: iptal edildi"
        exit 0
        ;;
esac

echo "$$" > "$PIDFILE" 2>/dev/null
log "basladi (pid $$), bekleme suresi ${DELAY}sn"

# ---------------------------------------------------------------------------
# 1) TWRP arayuzunun acilmasini bekle (recovery.log olusana kadar, en fazla 60 sn)
# ---------------------------------------------------------------------------
i=0
while [ ! -s /tmp/recovery.log ]; do
    i=$((i + 1))
    [ "$i" -ge 120 ] && break
    sleep 0.5
done
log "recovery.log hazir (tur=$i)"
sleep 2

# ---------------------------------------------------------------------------
# 2) Elle iptal isareti
# ---------------------------------------------------------------------------
# Hazir isaretleri: adb'den "ready" yazilmis mi?
for f in /tmp/ready /tmp/-ready /tmp/no-autoreboot /cache/.no-autoreboot; do
    if [ -e "$f" ]; then
        log "IPTAL: hazir isareti bulundu -> $f"
        exit 0
    fi
done

# ---------------------------------------------------------------------------
# 3) DELAY saniye boyunca girdi bekle
#    input_event yapisi 64-bit'te 24 bayt: time(16) + type(2) + code(2) + value(4)
#    type == 1 (EV_KEY)  -> dokunmatik dokunusu, ses/power tusu
#    type == 2 (EV_REL)  -> USB fare hareketi
#    Sadece bunlar iptal sebebi; EV_ABS (ham eksen) spam'i sayilmaz.
# ---------------------------------------------------------------------------
: > "$HIT" 2>/dev/null
rm -f "$STOP" 2>/dev/null

devs=0
for d in /dev/input/event*; do
    [ -e "$d" ] || continue
    devs=$((devs + 1))
    (
        while [ ! -e "$STOP" ]; do
            t=$(timeout 1 dd if="$d" bs=24 count=1 2>/dev/null \
                | od -An -tu2 -j16 -N2 2>/dev/null \
                | tr -d ' \n')
            case "$t" in
                1|2) echo "$d (type=$t)" >> "$HIT"; exit 0 ;;
            esac
        done
    ) &
done

# USB tarafi: karsi tarafta bir host (PC veya Termux) varsa da iptal say.
# /sys/class/udc/<udc>/state "configured" ise konfigurasyon uygulanmis
# demektir; yani biri baglanmis ve adb kullanıyor. Bu durumda 17 saniye
# sonra reboot etmek baglantiyi oldurur, o yuzden iptal.
(
    while [ ! -e "$STOP" ]; do
        if grep -qs configured /sys/class/udc/*/state 2>/dev/null; then
            echo "usb-configured" >> "$HIT"
            exit 0
        fi
        sleep 1
    done
) &

# adb/shell tarafindan "ready" isareti dusulmus mu?
# adb shell touch /tmp/ready   veya   adb shell touch /tmp/-ready
(
    while [ ! -e "$STOP" ]; do
        for f in /tmp/ready /tmp/-ready /tmp/no-autoreboot /cache/.no-autoreboot; do
            if [ -e "$f" ]; then
                echo "isaret:$f" >> "$HIT"
                exit 0
            fi
        done
        sleep 0.5
    done
) &

# TWRP'de bir ayar degisirse (kullanici menuyu kullaniyor) iptal.
# /data/.twrps TWRP'nin ayarlari; dokunmatik calisiyorsa zaten geri sayima
# gerek yok, o yuzden degisikligi iptal sayiyoruz.
if [ -f /data/.twrps ]; then
    base=$(ls -l /data/.twrps 2>/dev/null | awk '{print $6"_"$7"_"$8}')
    (
        while [ ! -e "$STOP" ]; do
            now=$(ls -l /data/.twrps 2>/dev/null | awk '{print $6"_"$7"_"$8}')
            if [ -n "$now" ] && [ "$now" != "$base" ]; then
                echo "twrp-ayari-degisti" >> "$HIT"
                exit 0
            fi
            sleep 1
        done
    ) &
fi

log "$devs girdi aygiti dinleniyor, ${DELAY}sn"
sleep "$DELAY"
: > "$STOP" 2>/dev/null
wait

if [ -s "$HIT" ]; then
    log "IPTAL: girdi algilandi -> $(tr '\n' ' ' < "$HIT")"
    exit 0
fi

log "girdi gelmedi, sisteme yeniden baslatiliyor"

# ---------------------------------------------------------------------------
# 4) Bootloader Control Block'u temizle (misc ilk 4096 bayt)
#    Boylece bootloader "recovery'ye ac" komutunu okumaz.
# ---------------------------------------------------------------------------
MISC=""
for p in /dev/block/by-name/misc \
         /dev/block/bootdevice/by-name/misc \
         /dev/block/platform/soc/*/by-name/misc; do
    if [ -b "$p" ]; then
        MISC="$p"
        break
    fi
done

if [ -n "$MISC" ]; then
    if dd if=/dev/zero of="$MISC" bs=4096 count=1 2>/dev/null; then
        log "BCB sifirlandi: $MISC"
    else
        log "UYARI: BCB yazilamadi: $MISC"
    fi
else
    log "UYARI: misc bolumu bulunamadi, sadece reboot"
fi

# TWRP'nin komut kuyrugu da temizlensin; yoksa bir sonraki aciliste
# "boot-recovery" bayragini geri yazabilir.
if [ -f /cache/recovery/command ]; then
    rm -f /cache/recovery/command 2>/dev/null
    log "/cache/recovery/command silindi"
fi

sync
sleep 1

# ---------------------------------------------------------------------------
# 5) Yeniden baslat.
#    ONEMLI: once DOGRUDAN reboot. misc zaten sifirlandigi icin bootloader
#    baska care bulamaz ve Android'i acar. 'twrp reboot' ancak bu olmazsa
#    denenir, cunku TWRP kendi BCB'sini yeniden yazma riski tasir.
# ---------------------------------------------------------------------------
log "dogrudan reboot (misc temiz, TWRP bayragi yok)"
sync
reboot

sleep 5
log "twrp reboot (yedek yol)"
timeout 10 twrp reboot >> "$LOG" 2>&1
log "twrp reboot bitti (cikis=$?)"

sleep 5
log "reboot -f (son care)"
reboot -f 2>/dev/null
