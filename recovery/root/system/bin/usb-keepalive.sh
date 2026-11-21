#!/system/bin/sh
#
# usb-keepalive.sh - TWRP acik oldugu surece USB'yi ayakta tutar.
#
# Her 2 saniyede bir:
#   1. /sys/bus/platform/devices altindaki tum *ssusb* / *dwc3*
#      kontrolculerini "peripheral" modunda tutar (host'a kayarsa geri alir)
#   2. sys.usb.config degerinde "adb" oldugundan emin olur
#   3. adbd kapaliysa yeniden baslatir
#   4. gadget bagli degilse UDC'yi yeniden yazar
#
# Boylece kablo ne zaman takilirsa takilsin (Termux veya PC) adb hazirdir.
# Log: /tmp/usb-keepalive.log
#

LOG=/tmp/usb-keepalive.log
log() { echo "[usbkeep] $*" >> "$LOG" 2>/dev/null; }

: > "$LOG"
log "basladi (pid $$)"

while :; do
    # --- 1) tum USB kontrolculerini device modunda tut ------------------------
    for d in /sys/bus/platform/devices/*; do
        n=$(basename "$d" 2>/dev/null)
        case "$n" in
            *ssusb* | *dwc3*) ;;
            *) continue ;;
        esac
        [ -w "$d/mode" ] || continue
        cur=$(cat "$d/mode" 2>/dev/null)
        if [ "$cur" != "peripheral" ]; then
            echo peripheral > "$d/mode" 2>>"$LOG"
            log "mode: $n '$cur' -> '$(cat "$d/mode" 2>/dev/null)'"
        fi
    done

    # --- 2) adb acik kalsin ---------------------------------------------------
    cfg=$(getprop sys.usb.config 2>/dev/null)
    case "$cfg" in
        *adb*) ;;
        *)
            log "sys.usb.config='$cfg' -> adb"
            setprop sys.usb.config adb 2>/dev/null
            ;;
    esac

    # --- 3) adbd ayakta mi ----------------------------------------------------
    svc=$(getprop init.svc.adbd 2>/dev/null)
    if [ "$svc" != "running" ]; then
        log "adbd=$svc, yeniden baslatiliyor"
        setprop ctl.start adbd 2>/dev/null
    fi

    # --- 4) gadget bagli mi ---------------------------------------------------
    udc=$(getprop sys.usb.controller 2>/dev/null)
    if [ -n "$udc" ] && [ -e "/sys/class/udc/$udc" ]; then
        bound=$(cat /config/usb_gadget/g1/UDC 2>/dev/null)
        if [ -z "$bound" ]; then
            log "gadget bagli degil, UDC yeniden yaziliyor: $udc"
            echo "$udc" > /config/usb_gadget/g1/UDC 2>>"$LOG"
        fi
    fi

    sleep 2
done