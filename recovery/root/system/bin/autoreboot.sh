#!/system/bin/sh
#
# autoreboot.sh - TWRP guvenlik agi (SM-A025F / a02q)
#
# Amac: TWRP acildiktan sonra 17 saniye icinde hicbir girdi (dokunmatik,
# tus, fare) gelmezse cihazi sisteme yeniden baslatir. Dokunmatik surucu
# calismadiginda cihaz TWRP'de kilitli kalip boot dongusune giriyor;
# bu betik o donguyu kirar.
#
# Iptal:
#   - Ekrana dokun / ses tusuna bas / fareyi oynat  -> 17 sn icinde iptal
#   - Ya da /tmp/no-autoreboot veya /cache/.no-autoreboot dosyasini olustur
#
# Log: /tmp/autoreboot.log  (ve /tmp/recovery.log)
#

LOG=/tmp/autoreboot.log
DELAY=17
HIT=/tmp/autoreboot.hit
STOP=/tmp/autoreboot.stop

log() {
    echo "[autoreboot] $*" >> "$LOG" 2>/dev/null
    echo "[autoreboot] $*" >> /tmp/recovery.log 2>/dev/null
}

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
if [ -e /tmp/no-autoreboot ] || [ -e /cache/.no-autoreboot ]; then
    log "IPTAL: isaret dosyasi bulundu"
    exit 0
fi

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
