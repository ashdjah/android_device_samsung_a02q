# vendorsetup.sh for Samsung Galaxy A02s (SM-A025F)
# TWRP device tree — Android 12

FDEVICE="a02q"

if [ "$1" = "$FDEVICE" ]; then
    export ALLOW_MISSING_DEPENDENCIES=true
    export LC_ALL="C"
fi
