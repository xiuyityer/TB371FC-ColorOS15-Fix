#!/system/bin/sh
set -eu

umask 077
module_dir=${0%/*}
exec >"$module_dir/service.log" 2>&1
printf 'start=%s\n' "$(date +%FT%T%z)"

# The sharing-declarations component mounted the interface XML during post-fs-data.
for attempt in $(seq 1 90); do
    [ "$(getprop sys.boot_completed)" != 1 ] || break
    sleep 2
done
[ "$(getprop sys.boot_completed)" = 1 ]
[ ! -e "$C15_MODULE_ROOT/disable" ] && [ ! -e "$C15_MODULE_ROOT/remove" ]
[ "$(getprop ro.boot.slot_suffix)" = _a ]
[ "$(uname -r)" = 4.19.325-perf++ ]
[ "$(uname -v | cut -d ' ' -f 1)" = '#789' ]
[ "$(getprop ro.build.fingerprint)" = 'OnePlus/OPD2413/OP615EL1:15/AP3A.240617.008/V.1ffac6c_1-12d5f:user/release-keys' ]
[ -r /odm/etc/vintf/manifest/c15-virtual-provider.xml ]
# Binder's shell command needs an stderr fd that system_server can write.
[ "$(/system/bin/pm has-feature android.hardware.telephony.subscription 2>/dev/null)" = true ] || {
    echo 'Subscription feature unavailable'
    exit 1
}

cd "$module_dir"
sha256sum -c SHA256SUMS
if ! grep -q '^oplus_vnet ' /proc/modules; then
    insmod "$module_dir/oplus_vnet.ko" numvnets=3
fi
for interface in ovnet0 ovnet1 ovnet2; do
    test -d "/sys/class/net/$interface"
done

export LD_LIBRARY_PATH="$module_dir/lib64:/vendor/lib64:/odm/lib64:/system_ext/lib64"
dmtp=vendor.oplus.hardware.communicationcenter.IDmtpService/default
case "$(service check "$dmtp")" in
    *': not found') ;;
    *) echo 'DMTP is already running or service check failed'; exit 1 ;;
esac

apk="$module_dir/OplusVirtualComm-slot-signal-guard.apk"
target=/system_ext/priv-app/OplusVirtualComm/OplusVirtualComm.apk
stock=e5af274500b6478a36aa1e69666596c9b6d81cc65d559b1e7b073cc54d558b3a
in_init() { nsenter -t 1 -m -- "$@"; }
file_hash() { sha256sum "$1" | cut -d ' ' -f 1; }
target_hash() { in_init sha256sum "$target" | cut -d ' ' -f 1; }
patched=$(file_hash "$apk")
[ "$(target_hash)" = "$stock" ] || { echo 'Unexpected stock VirtualComm APK'; exit 1; }
old_phone=$(pidof com.android.phone)

radio_pid=
comm_pid=
bound=0
cleanup() {
    [ -z "$radio_pid" ] || kill "$radio_pid" 2>/dev/null || true
    [ -z "$comm_pid" ] || kill "$comm_pid" 2>/dev/null || true
    if [ "$bound" = 1 ] && [ "$(target_hash)" = "$patched" ]; then
        in_init umount "$target" || in_init umount -l "$target"
        if [ "$(target_hash)" != "$stock" ]; then
            echo 'Original VirtualComm APK failed to reappear; reboot with provider disabled' >&2
            return 1
        fi
        pids=$(pidof com.android.phone || true)
        [ -z "$pids" ] || kill -TERM $pids 2>/dev/null || true
        echo 'Original VirtualComm APK restored'
    fi
}
trap cleanup EXIT
trap 'exit 1' TERM HUP INT

# PackageManager has already scanned the unmodified, signed APK during boot.
chcon u:object_r:system_file:s0 "$apk"
in_init mount --bind "$apk" "$target"
bound=1
[ "$(target_hash)" = "$patched" ]
kill -TERM $old_phone
phone_pid=
for attempt in $(seq 1 15); do
    phone_pid=$(pidof com.android.phone || true)
    if [ -n "$phone_pid" ] && [ "$phone_pid" != "$old_phone" ]; then
        break
    fi
    sleep 1
done
[ -n "$phone_pid" ] && [ "$phone_pid" != "$old_phone" ] || exit 1
[ "$(file_hash "/proc/$phone_pid/root$target")" = "$patched" ]

"$module_dir/commcenterd" >>"$module_dir/commcenter.log" 2>&1 &
comm_pid=$!
for attempt in $(seq 1 10); do
    kill -0 "$comm_pid"
    case "$(service check "$dmtp")" in
        *': found') break ;;
    esac
    sleep 1
done
[ "$(service check "$dmtp")" = "Service $dmtp: found" ]
"$module_dir/subsys_daemon" -l "$module_dir/lib64/lib-c15-radio-ims-onload.so" -i 0 >>"$module_dir/radio.log" 2>&1 &
radio_pid=$!
printf 'commcenter=%s radio=%s phone=%s apk=%s\n' "$comm_pid" "$radio_pid" "$phone_pid" "$patched"
# Leave each process stopped on failure so a persistent failure cannot crash-loop.
while kill -0 "$comm_pid" 2>/dev/null && kill -0 "$radio_pid" 2>/dev/null && kill -0 "$phone_pid" 2>/dev/null; do
    sleep 3
done
printf 'provider stopped at %s\n' "$(date +%FT%T%z)"
