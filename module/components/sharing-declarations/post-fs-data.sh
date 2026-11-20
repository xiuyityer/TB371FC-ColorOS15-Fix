#!/system/bin/sh
set -eu

moddir=${0%/*}
target=/system/etc/permissions
stage=/mnt/c15-sharing-subscription-test
logfile="$moddir/probe.log"
exec >"$logfile" 2>&1
trap 'echo "exit=$?"' EXIT

# A read-only overlay exposes one XML before SystemConfig scans permissions.
mkdir -p "$stage"
mount -t tmpfs -o mode=0755,size=64k tmpfs "$stage"
trap 'status=$?; umount "$stage" || true; rmdir "$stage" || true; echo "exit=$status"' EXIT
cp "$moddir/system/etc/permissions/c15-virtual-subscription-test.xml" "$stage/"
chmod 0644 "$stage/c15-virtual-subscription-test.xml"
chcon u:object_r:system_file:s0 "$stage" "$stage/c15-virtual-subscription-test.xml"
mount -t overlay -o "ro,lowerdir=$stage:$target" overlay "$target"
trap 'echo "exit=$?"' EXIT
ls -lZ "$target/c15-virtual-subscription-test.xml"

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
