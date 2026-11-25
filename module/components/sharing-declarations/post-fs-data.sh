#!/system/bin/sh
set -eu

moddir=${0%/*}
target=/system/etc/permissions
stage=/mnt/c15-sharing-subscription-test
logfile="$moddir/probe.log"
exec >"$logfile" 2>&1
trap 'echo "exit=$?"' EXIT

. "$moddir/../sharing-provider/common.sh"
if [ ! -r "$virtualcomm_target" ] || [ "$(file_hash "$virtualcomm_target")" != "$virtualcomm_stock" ]; then
    echo 'Missing or unexpected stock VirtualComm APK'
    exit 1
fi
if [ ! -d "$target" ] || [ ! -d /odm/etc/vintf/manifest ]; then
    echo 'Missing permissions or VINTF manifest directory'
    exit 1
fi

# A read-only overlay exposes the feature declarations before SystemConfig scans permissions.
mkdir -p "$stage"
mount -t tmpfs -o mode=0755,size=64k tmpfs "$stage"
trap 'status=$?; umount "$stage" || true; rmdir "$stage" || true; echo "exit=$status"' EXIT
chcon u:object_r:system_file:s0 "$stage"
for file in c15-virtual-subscription-test.xml c15-virtual-telephony.xml; do
    cp "$moddir/system/etc/permissions/$file" "$stage/"
    chmod 0644 "$stage/$file"
    chcon u:object_r:system_file:s0 "$stage/$file"
done
mount -t overlay -o "ro,lowerdir=$stage:$target" overlay "$target"
trap 'echo "exit=$?"' EXIT
ls -lZ "$target/c15-virtual-subscription-test.xml" "$target/c15-virtual-telephony.xml"

target=/odm/etc/vintf/manifest
stage=/mnt/c15-sharing-provider-test
mkdir -p "$stage"
mount -t tmpfs -o mode=0755,size=64k tmpfs "$stage"
trap 'status=$?; umount "$stage" || true; rmdir "$stage" || true; echo "exit=$status"' EXIT
cp "$moddir/vintf/c15-virtual-provider.xml" "$stage/"
chmod 0644 "$stage/c15-virtual-provider.xml"
chcon u:object_r:vendor_file:s0 "$stage" "$stage/c15-virtual-provider.xml"
mount -t overlay -o "ro,lowerdir=$stage:$target" overlay "$target"
trap 'echo "exit=$?"' EXIT
ls -lZ "$target/c15-virtual-provider.xml"

# Android creates its Phone objects before the late provider starts. Apply a
# boot-only default on the matched tablet stack, leaving stored settings intact.
case "$(getprop persist.radio.multisim.config)" in
    ''|ssss)
        if [ "$(getprop ro.telephony.sim_slots.count)" = 2 ]; then
            resetprop -n persist.radio.multisim.config dsds
        fi ;;
esac
