config=/my_product/etc/refresh_rate_config.xml
stock=dd1e8f11d959aaeaaf661116639074b8fd489d2792eecea014e006b6a336af1d
. "$module_dir/payload-hashes.sh"

check_device() {
        [ "$(getprop ro.product.board)" = spinel ] &&
        [ "$(getprop ro.boot.slot_suffix)" = _a ] &&
        [ "$(getprop ro.build.fingerprint)" = 'OnePlus/OPD2413/OP615EL1:15/AP3A.240617.008/V.1ffac6c_1-12d5f:user/release-keys' ] || {
        echo 'Unsupported device, slot, or ROM' >&2
        return 1
    }
}

require_hash() {
    [ "$(sha256sum "$1" | cut -d ' ' -f1)" = "$2" ] || {
        echo "Hash mismatch: $1" >&2
        return 1
    }
}
