#!/system/bin/sh
set -eu

umask 077
module_dir=${0%/*}
exec >"$module_dir/service.log" 2>&1
timestamp() { /system/bin/date +%FT%T%z; }
echo "start=$(timestamp)"

require() {
    if ! "$@"; then
        printf 'Check failed: %s\n' "$*" >&2
        exit 1
    fi
}

pkg=com.oplus.ipemanager
target=/my_product/priv-app/IPeManager/IPeManager.apk
source=$module_dir/IPeManager.plus-telemetry.apk
stock=d4e7b3f0c71b0cd24e8b6abee317302edcaef31916351c8377c31b92afc2752a
patch=00858670756349bbef76229d7c1d11d919cf9f92b62002b5119eb64cf3dec11f

prop() { /system/bin/getprop "$1"; }
pid_for() { /system/bin/pidof "$1"; }
single_pid() {
    case "$1" in ''|*[!0-9]*) return 1 ;; esac
}
check_apk() {
    local label=$1 path=$2 expected=$3 result
    if ! result=$(/system/bin/sha256sum "$path"); then
        echo "$label: cannot read $path"
        return 1
    fi
    result=${result%% *}
    echo "$label: $path sha256=$result"
    [ "$result" = "$expected" ]
}
in_zygote() { /system/bin/nsenter -t "$zygote" -m -- "$@"; }

# Always capture in a pipe: system_server cannot write the module's log FD.
android_cmd() { /system/bin/timeout 8 /system/bin/cmd "$@" </dev/null 2>&1; }
module_enabled() { [ ! -e "$C15_MODULE_ROOT/disable" ] && [ ! -e "$C15_MODULE_ROOT/remove" ]; }
parent_of() { /system/bin/awk '$1 == "PPid:" {print $2; exit}' "/proc/$1/status"; }
select_processes() {
    # Fresh app forks can briefly have the same name as their parent.
    zygote=$(prop init.svc_debug_pid.zygote)
    server=$(pid_for system_server) || return 1
    single_pid "$zygote" && single_pid "$server" &&
        [ "$(prop init.svc.zygote)" = running ] &&
        [ "$(parent_of "$zygote")" = 1 ] &&
        [ "$(/system/bin/readlink "/proc/$zygote/exe")" = /system/bin/app_process64 ] &&
        [ "$(parent_of "$server")" = "$zygote" ]
}

require test "$(prop ro.boot.slot_suffix)" = _a
require test "$(prop ro.build.fingerprint)" = 'OnePlus/OPD2413/OP615EL1:15/AP3A.240617.008/V.1ffac6c_1-12d5f:user/release-keys'
require test "$(/system/bin/getenforce)" = Enforcing

ready=0
attempt=0
while [ "$attempt" -lt 90 ]; do
    require module_enabled
    if [ "$(prop sys.boot_completed)" = 1 ]; then
        if user=$(android_cmd activity get-current-user) && [ "$user" = 0 ]; then
            if select_processes; then
                ready=1
                break
            fi
            echo "Waiting for init zygote and system_server: zygote=$zygote server=$server"
        else
            echo "ActivityManager not ready for user 0: $user"
        fi
    fi
    attempt=$((attempt + 1))
    /system/bin/sleep 2
done
require test "$ready" = 1

echo "init zygote=$zygote system_server=$server"
require test "$(android_cmd package path --user 0 "$pkg")" = "package:$target"
require check_apk init "/proc/1/root$target" "$stock"
require check_apk "system_server[$server]" "/proc/$server/root$target" "$stock"
require check_apk "zygote64[$zygote]" "/proc/$zygote/root$target" "$stock"
require check_apk payload "$source" "$patch"
require /system/bin/chcon u:object_r:system_file:s0 "$source"

stop_pen_app() {
    local output rc=0
    output=$(android_cmd activity stop-app --user 0 "$pkg") || rc=$?
    echo "stop-app rc=$rc: $output"
    [ "$rc" = 0 ] && [ -z "$output" ]
}

start_pen_service() {
    local output rc=0
    output=$(android_cmd activity start-service --user 0 \
        -a "$pkg.ACTION.PENCIL_SYSTEM" -n "$pkg/.btadsorb.CoreService") || rc=$?
    echo "start-service rc=$rc: $output"
    [ "$rc" = 0 ] || return 1
    case "$output" in 'Starting service:'*) return 0 ;; *) return 1 ;; esac
}

bound=0
cleanup() {
    rc=$?
    if [ "$bound" = 1 ]; then
        if in_zygote /system/bin/umount "$target" &&
            check_apk rollback "/proc/$zygote/root$target" "$stock"; then
            stop_pen_app && start_pen_service || echo 'Stock app restart failed; reboot'
        else
            echo 'Rollback failed; disable module and reboot'
        fi
    fi
    echo "exit=$rc at $(timestamp)"
}
trap cleanup EXIT
trap 'exit 1' TERM HUP INT

require module_enabled
require test "$(prop init.svc_debug_pid.zygote)" = "$zygote"
old_ui=$(pid_for "$pkg" || true)
old_ble=$(pid_for "$pkg:ble" || true)
# PackageManager continues reading the original signed APK.
require in_zygote /system/bin/mount -o bind "$source" "$target"
bound=1
require check_apk "zygote64[$zygote]" "/proc/$zygote/root$target" "$patch"
require check_apk init "/proc/1/root$target" "$stock"
require check_apk "system_server[$server]" "/proc/$server/root$target" "$stock"

loaded=0
for attempt in 1 2 3; do
    require module_enabled
    echo "restart attempt=$attempt old_ui=$old_ui old_ble=$old_ble"
    if stop_pen_app && start_pen_service; then
        for delay in 1 2 3 4 5; do
            ble=$(pid_for "$pkg:ble" || true)
            ui=$(pid_for "$pkg" || true)
            if single_pid "$ble" && [ "$ble" != "$old_ble" ] &&
                { [ -z "$ui" ] || { single_pid "$ui" && [ "$ui" != "$old_ui" ]; }; }; then
                if check_apk "$pkg:ble[$ble]" "/proc/$ble/root$target" "$patch" &&
                    { [ -z "$ui" ] || check_apk "$pkg[$ui]" "/proc/$ui/root$target" "$patch"; }; then
                    loaded=1
                    break 2
                fi
            fi
            /system/bin/sleep 1
        done
    fi
    /system/bin/sleep 2
done
require test "$loaded" = 1
require module_enabled
echo "active apk=$patch at $(timestamp)"
trap - EXIT HUP INT TERM
