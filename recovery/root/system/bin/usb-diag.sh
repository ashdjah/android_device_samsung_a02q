#!/system/bin/sh
# usb-diag.sh - a02q recovery USB role / adbd state capture (READ ONLY)
# Calistir: sh /sdcard/Download/usb-diag.sh
# Cikti: /tmp/usb-diag.txt (ayrica ekrana basar)
# Hicbir sey degistirmez: sadece okur.

OUT=/tmp/usb-diag.txt
: > "$OUT" 2>/dev/null

say() {
    printf '%s\n' "$*"
    printf '%s\n' "$*" >> "$OUT" 2>/dev/null
}

section() {
    say ""
    say "===== $* ====="
}

# Sinirsiz glob'lara karsi sabit tavan.
CEIL=64

section "ZAMAN / UPTIME"
date 2>/dev/null
cat /proc/uptime 2>/dev/null

section "PROPLAR"
for p in \
    sys.usb.controller ro.boot.usbcontroller ro.boot.usb.dwc3_msm \
    sys.usb.config sys.usb.state sys.usb.ffs.ready \
    init.svc.adbd init.svc.usbkeep init.svc.usbperiph \
    init.svc.autoreboot vendor.usb.controller; do
    v=$(getprop "$p" 2>/dev/null)
    [ -n "$v" ] && say "$p = $v" || say "$p = <yok>"
done

section "TUM USB PROPLARI"
getprop 2>/dev/null | grep -iE 'usb|adb' 2>/dev/null | head -n 80

section "ADBD 5s SAMPLING (1 sn aralikla)"
i=0
while [ "$i" -lt 5 ]; do
    i=$((i + 1))
    pids=$(ps -A 2>/dev/null | grep '[a]dbd' 2>/dev/null | wc -l 2>/dev/null)
    say "ornek $i: svc=$(getprop init.svc.adbd 2>/dev/null) pid_sayisi=$pids cfg=$(getprop sys.usb.config 2>/dev/null) udc=$(cat /sys/class/udc/*/state 2>/dev/null | head -n 1)"
    [ "$i" -lt 5 ] && sleep 1
done

section "SURECLER"
ps -A 2>/dev/null | grep -E 'adbd|usb-keepalive|usb-peripheral|autoreboot' 2>/dev/null
say "(bos liste = ilgili surec yok)"

section "UDC (CIHAZ TARAFI)"
n=0
for u in /sys/class/udc/*; do
    [ -e "$u" ] || continue
    n=$((n + 1))
    [ "$n" -gt "$CEIL" ] && break
    say "--- $u"
    say "state    = $(cat "$u/state" 2>/dev/null)"
    say "function = $(cat "$u/function" 2>/dev/null)"
done
[ "$n" -eq 0 ] && say "<hicbir UDC gorunmuyor>"

section "DWC3 / SSUSB MODU DUGUMLERI"
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
    say "--- $name"
    say "mode  = $(cat "$d/mode" 2>/dev/null)"
    say "state = $(cat "$d/state" 2>/dev/null)"
    for f in "$d/uevent" "$d/otg-state" "$d/role"; do
        [ -r "$f" ] && say "$(basename "$f") = $(head -n 4 "$f" 2>/dev/null | tr '\n' ' ')"
    done
done
[ "$n" -eq 0 ] && say "<mode dugumu yok>"

section "USB BUS (OTG TARAFI)"
n=0
for d in /sys/bus/usb/devices/*; do
    [ -d "$d" ] || continue
    n=$((n + 1))
    [ "$n" -gt "$CEIL" ] && break
    name=$(basename "$d" 2>/dev/null)
    p=$(cat "$d/product" 2>/dev/null)
    m=$(cat "$d/manufacturer" 2>/dev/null)
    c=$(cat "$d/bDeviceClass" 2>/dev/null)
    say "$name | product=${p:-?} | manufacturer=${m:-?} | class=${c:-?}"
done
[ "$n" -eq 0 ] && say "<bus bos>"

section "GADGET CONFIGFS"
say "UDC        = $(cat /config/usb_gadget/g1/UDC 2>/dev/null)"
say "config     = $(cat /config/usb_gadget/g1/configs/b.1/strings/0x409/configuration 2>/dev/null)"
say "idVendor   = $(cat /config/usb_gadget/g1/idVendor 2>/dev/null)"
say "idProduct  = $(cat /config/usb_gadget/g1/idProduct 2>/dev/null)"
n=0
for f in /config/usb_gadget/g1/configs/b.1/f[0-9]*; do
    [ -e "$f" ] || continue
    n=$((n + 1))
    [ "$n" -gt 16 ] && break
    say "func $f -> $(readlink "$f" 2>/dev/null)"
done
[ "$n" -eq 0 ] && say "<config bos>"

section "FFS MOUNT"
mount 2>/dev/null | grep usb-ffs 2>/dev/null
say "(ustte hic satir yoksa functionfs mount yok)"

section "IPTAL / FAILSAFE ISARETLERI"
for f in /tmp/ready /tmp/-ready /tmp/no-autoreboot /cache/.no-autoreboot \
         /tmp/autoreboot.hit /tmp/autoreboot.stop /tmp/autoreboot.pid \
         /cache/.autoreboot_attempts /cache/.autoreboot_last; do
    if [ -e "$f" ]; then
        say "$f = VAR (icerik: $(head -c 128 "$f" 2>/dev/null | tr '\n' ' '))"
    else
        say "$f = yok"
    fi
done

section "LOG: usb-keepalive.log (son 80)"
tail -n 80 /tmp/usb-keepalive.log 2>/dev/null
section "LOG: usb-peripheral.log (son 80)"
tail -n 80 /tmp/usb-peripheral.log 2>/dev/null
section "LOG: autoreboot.log (son 60)"
tail -n 60 /tmp/autoreboot.log 2>/dev/null
section "LOG: recovery.log - USB/adbd/dwc3 (son 80)"
grep -iE 'usb|adbd|dwc3|gadget|otg|ffs' /tmp/recovery.log 2>/dev/null | tail -n 80

section "DMESG - USB/adbd/dwc3 (son 80)"
dmesg 2>/dev/null | grep -iE 'dwc3|usb|adb|gadget|role|otg|phy' 2>/dev/null | tail -n 80

say ""
say "DONE -> $OUT"
