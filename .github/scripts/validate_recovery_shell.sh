#!/usr/bin/env bash
# Guard the recovery shell layer: every tracked ramdisk script must be valid
# /system/bin/sh, carry the device shebang and keep its executable git mode.
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/../.." && pwd)
cd "$repo_root"

errors=0
fail() {
    echo "FAIL: $*" >&2
    errors=$((errors + 1))
}

scripts=$(git ls-files 'recovery/root/system/bin/*.sh')
if [ -z "$scripts" ]; then
    fail "no recovery shell scripts found"
fi

while IFS= read -r script; do
    [ -n "$script" ] || continue

    if ! sh -n "$script" 2>&1; then
        fail "shell syntax: $script"
    fi

    if ! head -n 1 "$script" | grep -qx '#!/system/bin/sh'; then
        fail "expected #!/system/bin/sh shebang: $script"
    fi

    mode=$(git ls-files -s -- "$script" | awk '{print $1}')
    if [ "$mode" != "100755" ]; then
        fail "expected git mode 100755, found ${mode:-none}: $script"
    fi
done <<EOF
$scripts
EOF

if [ "$errors" -ne 0 ]; then
    echo "$errors recovery shell error(s)" >&2
    exit 1
fi

echo "recovery shell OK"
