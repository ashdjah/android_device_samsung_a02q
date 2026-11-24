#!/usr/bin/env bash
# Validate recovery/root/system/etc/twrp.fstab against TWRP android-12.1's
# partition.cpp parser: v1 lines are <mount point> <fstype> <block device>
# [alternate device] [flags=...]. Bare tokens such as "logical" or "display="
# are silently ignored by that parser and must be rejected here.
set -euo pipefail

fstab="${1:-recovery/root/system/etc/twrp.fstab}"
if [ ! -f "$fstab" ]; then
    echo "FAIL: fstab not found: $fstab" >&2
    exit 1
fi

errors=0
fail() {
    echo "FAIL: $*" >&2
    errors=$((errors + 1))
}

parsed=$(mktemp)
trap 'rm -f "$parsed"' EXIT

if ! awk '
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    {
        # TWRP toggles quote state while splitting: display="System Image"
        # is one token, not two. Mirror that before reading fields.
        raw = $0
        len = length(raw)
        clean = ""
        quoted = 0
        sep = sprintf("%c", 31)
        for (i = 1; i <= len; i++) {
            c = substr(raw, i, 1)
            if (c == "\"") quoted = !quoted
            if (quoted == 0 && c ~ /[[:space:]]/) c = " "
            else if (quoted == 1 && c == " ") c = sep
            clean = clean c
        }
        gsub(/^ +| +$/, "", clean)
        count = split(clean, field, / +/)
        if (count < 3) {
            print "too few columns: line " NR > "/dev/stderr"
            bad = 1
            next
        }
        for (j = 1; j <= count; j++) gsub(sep, " ", field[j])

        mp = field[1]; fs = field[2]; dev = field[3]; flags = ""
        for (i = 4; i <= count; i++) {
            token = field[i]
            if (token ~ /^flags=/) {
                flags = substr(token, 7)
            } else if (token ~ /^\//) {
                # alternate block device
            } else if (token ~ /^length=/) {
                # partition length
            } else if (token == "NULL" || token == "null") {
                # explicit empty value
            } else {
                print "bare token: line " NR " partition " mp " token " token > "/dev/stderr"
                bad = 1
            }
        }
        if (mp !~ /^\//) {
            print "mount point must start with /: line " NR " value " mp > "/dev/stderr"
            bad = 1
        }
        if (dev !~ /^\/dev\//) {
            print "block device must be an absolute /dev/ path: line " NR " value " dev > "/dev/stderr"
            bad = 1
        }
        if (seen[mp]++) {
            print "duplicate mount point: line " NR " value " mp > "/dev/stderr"
            bad = 1
        }
        print mp "|" fs "|" dev "|" flags
    }
    END { exit bad ? 1 : 0 }
' "$fstab" > "$parsed"; then
    errors=$((errors + 1))
fi

lookup() {
    awk -F'|' -v key="$1" '$1 == key { print; exit }' "$parsed"
}

for name in system vendor product odm; do
    mount_point="/$name"
    mapper="/dev/block/mapper/$name"
    image_point="/${name}_image"

    entry=$(lookup "$mount_point")
    if [ -z "$entry" ]; then
        fail "missing dynamic partition entry $mount_point"
        continue
    fi

    device=$(printf '%s\n' "$entry" | cut -d'|' -f3)
    if [ "$device" != "$mapper" ]; then
        fail "$mount_point must use $mapper, found $device"
    fi

    flags=$(printf '%s\n' "$entry" | cut -d'|' -f4)
    case ";$flags;" in
        *";logical;"*) ;;
        *) fail "$mount_point flags must contain logical" ;;
    esac

    image=$(lookup "$image_point")
    if [ -z "$image" ]; then
        fail "missing GUI wipe target $image_point"
        continue
    fi

    image_device=$(printf '%s\n' "$image" | cut -d'|' -f3)
    if [ "$image_device" != "$mapper" ]; then
        fail "$image_point must use $mapper, found $image_device"
    fi

    image_flags=$(printf '%s\n' "$image" | cut -d'|' -f4)
    for required in wipeingui flashimg; do
        case ";$image_flags;" in
            *";$required;"* | *";$required=1;"* | *";$required=y;"* | *";$required=Y;"*) ;;
            *) fail "$image_point flags must contain $required" ;;
        esac
    done
done

if [ "$errors" -ne 0 ]; then
    echo "$errors fstab error(s) in $fstab" >&2
    exit 1
fi

echo "twrp.fstab OK: $fstab"
