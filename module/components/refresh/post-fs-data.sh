#!/system/bin/sh
set -eu

module_dir=${0%/*}
. "$module_dir/common.sh"
umask 077
exec >"$module_dir/mount.log" 2>&1
trap 'echo "exit=$?"' EXIT
require_hash "$config" "$stock"
require_hash "$module_dir/refresh_rate_config.xml" "$replacement"
chcon u:object_r:system_file:s0 "$module_dir/refresh_rate_config.xml"
mount -o bind "$module_dir/refresh_rate_config.xml" "$config"
if ! require_hash "$config" "$replacement"; then
    umount "$config"
    exit 1
fi
echo 'C15 refresh policy mounted before system_server'
