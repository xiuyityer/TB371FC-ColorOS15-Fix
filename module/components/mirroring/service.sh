#!/system/bin/sh
set -eu

umask 077
module_dir=${0%/*}
exec >"$module_dir/service.log" 2>&1
trap 'rc=$?; echo "exit=$rc at $(date +%FT%T%z)"' EXIT
echo "start=$(date +%FT%T%z)"

require() {
    if ! "$@"; then
        printf 'Check failed: %s\n' "$*" >&2
        exit 1
    fi
}

for attempt in $(seq 1 90); do
    [ "$(getprop sys.boot_completed)" != 1 ] || break
    sleep 2
done
require test "$(getprop sys.boot_completed)" = 1
require test ! -e "$C15_MODULE_ROOT/disable"
require test ! -e "$C15_MODULE_ROOT/remove"

pkg=com.oplus.padconnect
apk=/my_stock/priv-app/PadConnect/PadConnect.apk
jar=/system_ext/framework/oplusex/com.oplus.odmf/odmf.jar
stock_apk=9f3c2fba2a99c3ab5c0924fe7b5efeb04a4a44901e98a540e1d3a7e74e21e22d
stock_jar=628595d2cd39df8a47abc43c74a55232e3a4a0d92a02700821a02bcc1deb5e3d
patch_apk=c18c24cad66cc85ade05ca6d413edfa651b497b2e85689155c7166e21a1dcf6a
patch_jar=115e6e19452ba9f159d91633d8f8c5e96fd34ff4e5049d580c6ce1f88c9e12ed
apk_source=$module_dir/PadConnect.actual-display.test.apk
jar_source=$module_dir/odmf.surface.jar
zygote=$(getprop init.svc_debug_pid.zygote)
server=$(pidof system_server)
file_digest() { sha256sum "$1" | cut -d ' ' -f1; }
pid_is_single() {
    case "$1" in
        ''|*[!0-9]*) return 1 ;;
    esac
}
in_zygote() { nsenter -t "$zygote" -m -- "$@"; }
hash_for() { file_digest "/proc/$1/root$2"; }
stock_for() {
    require test "$(hash_for "$1" "$jar")" = "$stock_jar"
    require test "$(hash_for "$1" "$apk")" = "$stock_apk"
}

require pid_is_single "$zygote"
require pid_is_single "$server"
require test "$(pm path "$pkg" 2>/dev/null)" = "package:$apk"
require grep -q ' /mnt/opex/com.oplus.odmf@15002009 ' "/proc/$zygote/mountinfo"
stock_for 1
stock_for "$server"
stock_for "$zygote"
require test "$(file_digest "$jar_source")" = "$patch_jar"
require test "$(file_digest "$apk_source")" = "$patch_apk"
require chcon u:object_r:system_file:s0 "$jar_source" "$apk_source"
echo "Stock scanned; OPEX ready; zygote64=$zygote system_server=$server"

jar_bound=0
apk_bound=0
cleanup() {
    rc=$?
    # Roll back only mounts made by this invocation, in reverse order.
    if [ "$apk_bound" = 1 ]; then
        in_zygote umount "$apk" || echo 'APK unmount failed; disable module and reboot'
    fi
    if [ "$jar_bound" = 1 ]; then
        in_zygote umount "$jar" || echo 'JAR unmount failed; disable module and reboot'
    fi
    if [ "$apk_bound$jar_bound" != 00 ]; then
        am force-stop --user 0 "$pkg" >/dev/null 2>&1 || true
    fi
    echo "exit=$rc at $(date +%FT%T%z)"
}
trap cleanup EXIT
trap 'exit 1' TERM HUP INT

# PackageManager keeps the original APK; later zygote children see the pair.
require in_zygote mount -o bind "$jar_source" "$jar"
jar_bound=1
require test "$(hash_for "$zygote" "$jar")" = "$patch_jar"
require in_zygote mount -o bind "$apk_source" "$apk"
apk_bound=1
require test "$(hash_for "$zygote" "$apk")" = "$patch_apk"
stock_for 1
stock_for "$server"
if pidof "$pkg" >/dev/null; then
    am force-stop --user 0 "$pkg" >/dev/null 2>&1 || {
        echo 'PadConnect stop failed' >&2
        exit 1
    }
fi
echo "active jar=$patch_jar apk=$patch_apk at $(date +%FT%T%z)"
trap - EXIT HUP INT TERM
