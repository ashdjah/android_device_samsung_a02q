#!/system/bin/sh
#
# usb-peripheral.sh - dwc3 kontrolcusunu "peripheral" (device) moduna zorlar.
#
# Neden gerekli:
#   Bu cihazda bootloader dwc3'u "host" modunda birakabiliyor. Host modunda
#   gadget (configfs) baglansa bile karsi tarafa hicbir sey enumerate olmaz:
#   adb cikar ama USB'de gorunmez. Ragekill agacindaki
#   init.recovery.qcom.rc tam bu noktada "mode peripheral" yaziyordu; bizim
#   agacta o blok yoktu, sadece sys.usb.controller set ediliyordu.
#
# Log: /tmp/usb-peripheral.log
#

LOG=/tmp/usb-peripheral.log
log() { echo "[usbperiph] $*" >> "$LOG" 2>/dev/null; }

: > "$LOG"
log "basladi (pid $$)"

# --- hangi UDC? ---------------------------------------------------------------
UDC=$(getprop sys.usb.controller 2>/dev/null)
[ -z "$UDC" ] && UDC=$(getprop ro.boot.usbcontroller 2>/dev/null)
log "sys.usb.controller = ${UDC:-<bos>}"

# --- dwc3 "mode" dugumlerini bul ---------------------------------------------
NODES=""
for d in /sys/bus/platform/devices/*; do
    n=$(basename "$d" 2>/dev/null)
    case "$n" in
        *ssusb* | *dwc3*)
            [ -w "$d/mode" ] && NODES="$NODES $d/mode"
            ;;
    esac
done

# Bilinen acik adresler (msm8953 = a600000, yeni nesil = 7000000)
for c in "$UDC" a600000.ssusb 7000000.ssusb 7000000.dwc3; do
    [ -n "$c" ] || continue
    p="/sys/bus/platform/devices/$c/mode"
    [ -w "$p" ] && NODES="$NODES $p"
done

# tekrarları at
UNIQ=""
for n in $NODES; do
    case " $UNIQ " in
        *" $n "*) ;;
        *) UNIQ="$UNIQ $n" ;;
    esac
done

if [ -z "$UNIQ" ]; then
    log "UYARI: hicbir 'mode' dugumu bulunamadi (kernel bu attribute'u sallamiyor olabilir)"
else
    for n in $UNIQ; do
        before=$(cat "$n" 2>/dev/null)
        if echo peripheral > "$n" 2>>"$LOG"; then
            after=$(cat "$n" 2>/dev/null)
            log "OK   $n : '$before' -> '$after'"
        else
            log "HATA $n yazilamadi (mevcut: ${before:-?})"
        fi
    done
fi

# --- UDC hazir mi? -----------------------------------------------------------
if [ -n "$UDC" ]; then
    i=0
    while [ "$i" -lt 20 ]; do
        [ -e "/sys/class/udc/$UDC" ] && { log "udc hazir: $UDC"; break; }
        i=$((i + 1))
        sleep 0.5
    done
    [ "$i" -ge 20 ] && log "UYARI: /sys/class/udc/$UDC gorunmedi"
fi

log "bitti"