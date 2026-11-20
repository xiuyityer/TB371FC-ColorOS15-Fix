ADB_ROOT=/data/adb

supported_device() {
    [ "$(getprop ro.product.board)" = spinel ] &&
        [ "$(getprop ro.boot.slot_suffix)" = _a ] &&
        [ "$(getprop ro.build.fingerprint)" = 'OnePlus/OPD2413/OP615EL1:15/AP3A.240617.008/V.1ffac6c_1-12d5f:user/release-keys' ] &&
        [ "$(uname -r)" = 4.19.325-perf++ ] &&
        [ "$(uname -v | cut -d ' ' -f 1)" = '#789' ] &&
        [ "$(getenforce)" = Enforcing ]
}

module_enabled() { [ ! -e "$MODROOT/disable" ] && [ ! -e "$MODROOT/remove" ]; }

no_legacy_modules() {
    local id installed pending conflict=0
    for id in c15_sharing_subscription_test c15_sharing_provider_test \
        c15_mirroring_test c15_refresh_pen c15_native_pen; do
        installed=$ADB_ROOT/modules/$id
        pending=$ADB_ROOT/modules_update/$id
        if { [ -d "$installed" ] && [ ! -e "$installed/disable" ] && [ ! -e "$installed/remove" ]; } ||
            [ -d "$pending" ]; then
            echo "Conflicting installed or pending module: $id"
            conflict=1
        fi
    done
    [ "$conflict" = 0 ]
}
