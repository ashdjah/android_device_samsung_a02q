#!/system/bin/sh
#
# usb-keepalive.sh - TWRP acikken adb/gadget baglantisini ayakta tutar.
#
# Her 2 saniyede bir:
#   1. Rolü SABITLEMEZ. Sadece bootloader'in "none" biraktigi belirsiz
#      durumu peripheral'a cevirir (bir kez). "host" veya "otg" degerlerine
#      dokunmaz; aksi halde OTG fare/klavye bir daha host moduna gecemez.
#   2. sys.usb.config icinde "adb" oldugundan emin olur.
#   3. adbd kapaliysa yeniden baslatir ve sonucu loglar.
#   4. Gadget UDC'yi baglar / kopmussa yeniden baglar.
#      sys.usb.controller yanlis veya bossa gercek UDC'yi /sys/class/udc'den alir.
#
# Gecmis: 8fabd98 her 2 sn tum mode dugumlerine "peripheral" yaziyordu.
# 0674666 bus doluysa host'u birakacak bir guard ekledi; ama onceki yazis
# zaten rolu peripheral'a sabitlediginden bus hicbir zaman dolmuyordu.
# 20261122d sonrasi OTG ve PC tarafi birlikte olmasi bu yuzden imkansizdi.
#
# Log: /tmp/usb-keepalive.log
#

LOG=/tmp/usb-keepalive.log
log() { echo "[usbkeep] $*" >> "$LOG" 2>/dev/null; }

: > "$LOG"
log "basladi (pid $$)"

# Sinirsiz glob'lara karsi sabit tavan.
CEIL=64

while :; do
    # --- 1) Sadece belirsiz "none" rolunu normalize et -------------------------
    # Host/otg/peripheral degerlerine dokunma. Cihaz tek DWC3 portunu hem PC
    # (device) hem OTG (host) icin kullaniyor; sabit yazis iki rolden birini oldurur.
    n=0
    for d in /sys/bus/platform/devices/*; do
        [ -d "$d" ] || continue
        name=$(basename "$d" 2>/dev/null)
        case "$name" in
            *ssusb* | *dwc3*) ;;
            *) continue ;;
        esac
        n=$((n + 1))
        [ "$n" -gt "$CEIL" ] && break
        [ -w "$d/mode" ] || continue
        cur=$(cat "$d/mode" 2>/dev/null)
        [ "$cur" = "none" ] || continue
        if echo peripheral > "$d/mode" 2>>"$LOG"; then
            log "mode: $name 'none' -> '$(cat "$d/mode" 2>/dev/null)' (tek sefer)"
        else
            log "HATA: $name 'none' -> peripheral yazilamadi"
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
        log "adbd=$svc, ctl.start deneniyor"
        setprop ctl.start adbd 2>/dev/null
        sleep 1
        log "adbd sonrasi: $(getprop init.svc.adbd 2>/dev/null)"
    fi

    # --- 4) Gerekirse gercek UDC'yi prop'a yaz --------------------------------
    udc=$(getprop sys.usb.controller 2>/dev/null)
    if [ -z "$udc" ] || [ ! -e "/sys/class/udc/$udc" ]; then
        for u in /sys/class/udc/*; do
            [ -d "$u" ] || continue
            found=$(basename "$u" 2>/dev/null)
            [ -n "$found" ] || continue
            log "sys.usb.controller='$udc' gecersiz, '$found' kullaniliyor"
            udc=$found
            setprop sys.usb.controller "$found" 2>/dev/null
            break
        done
    fi

    # --- 5) Gadget bagli mi ---------------------------------------------------
    if [ -n "$udc" ] && [ -e "/sys/class/udc/$udc" ] && [ -e /config/usb_gadget/g1/UDC ]; then
        bound=$(cat /config/usb_gadget/g1/UDC 2>/dev/null)
        if [ "$bound" != "$udc" ]; then
            log "gadget UDC='$bound' -> '$udc' yeniden baglaniyor"
            echo "$udc" > /config/usb_gadget/g1/UDC 2>>"$LOG"
        fi
    fi

    sleep 2
done
