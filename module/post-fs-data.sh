#!/system/bin/sh
set -eu
umask 077
MODROOT=${0%/*}
. "$MODROOT/common.sh"
exec >"$MODROOT/early.log" 2>&1
module_enabled || exit 0
no_legacy_modules || exit 1

status=0
for component in sharing-declarations refresh; do
    module_enabled || exit 0
    rc=0
    sh "$MODROOT/components/$component/post-fs-data.sh" || rc=$?
    printf '%s rc=%s\n' "$component" "$rc"
    [ "$rc" = 0 ] || status=1
done
exit "$status"
