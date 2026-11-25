config=/my_product/etc/refresh_rate_config.xml
stock=dd1e8f11d959aaeaaf661116639074b8fd489d2792eecea014e006b6a336af1d
. "$module_dir/payload-hashes.sh"

require_hash() {
    [ "$(sha256sum "$1" | cut -d ' ' -f1)" = "$2" ] || {
        echo "Hash mismatch: $1" >&2
        return 1
    }
}
