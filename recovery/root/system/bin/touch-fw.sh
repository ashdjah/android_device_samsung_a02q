#!/system/bin/sh
#
# touch-fw.sh - ICNL9911C/Chipone CTS touch firmware loader for SM-A025F
#
# Stock vendor ships chipone-tddi.bin but the CTS driver in this prebuilt
# kernel often fails to load it at boot (fwid stays 0000, driver_builtin_firmware INVALID).
# Force-load via sysfs update_from_file once the node is present.
#
# Evidence (2026-11-22, TWRP 20261122c, Bugjaeger adb): hwid 991110 ICNL9911C,
# /vendor/firmware/chipone-tddi.bin sha256 9304d51f684722da915a0f321252f0b23f932d11907054eabb20d3ed3ccbf0cd,
# curr_version becomes 0205 after update_from_file and touch works.

LOG=/tmp/touch-fw.log
log() { echo "[touch-fw] $*" >> "$LOG"; }

FW=""
for f in /vendor/firmware/chipone-tddi.bin /system/vendor/firmware/chipone-tddi.bin /odm/firmware/chipone-tddi.bin; do
    [ -f "$f" ] && FW="$f" && break
done

if [ -z "$FW" ]; then
    log "firmware not found"
    exit 0
fi

NODE=""
for i in $(seq 1 30); do
    for n in \
        /sys/devices/platform/soc/78b7000.spi/spi_master/spi3/spi3.3/cts_firmware/update_from_file \
        /sys/bus/spi/devices/spi3.3/cts_firmware/update_from_file; do
        if [ -w "$n" ]; then
            NODE="$n"
            break 2
        fi
    done
    sleep 1
done

if [ -z "$NODE" ]; then
    log "update_from_file node not found"
    exit 0
fi

CUR_VER=$(cat "$(dirname "$NODE")/curr_version" 2>/dev/null)
log "before: $CUR_VER fw=$FW node=$NODE"
echo "$FW" > "$NODE" 2>>"$LOG"
sleep 2
NEW_VER=$(cat "$(dirname "$NODE")/curr_version" 2>/dev/null)
log "after: $NEW_VER"
