#!/system/bin/sh
set -eu
umask 077
MODROOT=${0%/*}
. "$MODROOT/common.sh"
exec >"$MODROOT/late.log" 2>&1
module_enabled || exit 0
supported_device || { echo 'Unsupported target'; exit 1; }
no_legacy_modules || exit 1
export C15_MODULE_ROOT="$MODROOT"

run_component() {
    module_enabled || return 0
    echo "starting $1"
    rc=0
    sh "$MODROOT/components/$1/service.sh" </dev/null || rc=$?
    printf '%s exited rc=%s\n' "$1" "$rc"
}

# The sharing provider and refresh bridge stay alive; never block other fixes.
run_component sharing-provider &
provider=$!
run_component refresh &
refresh=$!
run_component mirroring
run_component native-pen
wait "$provider"
wait "$refresh"
