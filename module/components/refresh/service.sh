#!/system/bin/sh
set -eu

module_dir=${0%/*}
. "$module_dir/common.sh"
state=/data/adb/c15-refresh-pen
root=${C15_MODULE_ROOT:?}
umask 077
exec >"$module_dir/service.log" 2>&1
trap 'echo "exit=$?"' EXIT
for attempt in $(seq 1 90); do
    [ "$(getprop sys.boot_completed)" != 1 ] || break
    sleep 2
done
[ "$(getprop sys.boot_completed)" = 1 ]
[ ! -e "$root/disable" ] && [ ! -e "$root/remove" ]
[ "$(am get-current-user 2>/dev/null)" = 0 ]
server=$(pidof system_server)
require_hash "/proc/$server/root$config" "$replacement"
require_hash "$module_dir/pen-refresh" "$bridge"
if [ ! -r /proc/fw_pen_state ] || [ ! -r /sys/class/drm/card0-DSI-1/dpms ]; then
    echo 'Pen state or display power interface unavailable'
    exit 1
fi
[ ! -L "$state" ]
mkdir -p "$state"
chmod 0700 "$state"
"$module_dir/pen-refresh" --restore "$root" "$state"

native=$(settings get secure oplus_customize_screen_refresh_rate 2>/dev/null)
peak=$(settings get system peak_refresh_rate 2>/dev/null)
case "$native:$peak" in
    3:null|3:120|3:120.0|3:120.00001|4:null|4:120|4:120.0|4:120.00001|4:144|4:144.0|null:null)
        settings put secure oplus_customize_screen_refresh_rate 4 >/dev/null 2>&1
        settings put system peak_refresh_rate 144.00002 >/dev/null 2>&1
        ;;
esac
printf 'idle selector=%s peak=%s\n' \
    "$(settings get secure oplus_customize_screen_refresh_rate 2>/dev/null)" \
    "$(settings get system peak_refresh_rate 2>/dev/null)"
if [ -f "$state/bridge.log" ] && [ "$(wc -c < "$state/bridge.log")" -gt 262144 ]; then
    mv -f "$state/bridge.log" "$state/bridge.previous.log"
fi
exec "$module_dir/pen-refresh" --run "$root" "$state" </dev/null >>"$state/bridge.log" 2>&1
