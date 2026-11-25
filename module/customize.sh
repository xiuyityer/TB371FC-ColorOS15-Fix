SKIPMOUNT=true
MODROOT=$MODPATH
. "$MODROOT/common.sh"

[ "$BOOTMODE" = true ] || abort 'Install from KernelSU Manager in Android.'
no_legacy_modules || abort 'Disable the five legacy C15 modules and resolve any pending updates first.'
(cd "$MODROOT" && sha256sum -c SHA256SUMS) || abort 'Package integrity check failed.'

touch "$MODROOT/skip_mount" || abort 'Cannot disable automatic module mounting.'
set_perm_recursive "$MODROOT" 0 0 0755 0644
for file in post-fs-data.sh service.sh components/sharing-declarations/post-fs-data.sh \
    components/sharing-provider/service.sh components/sharing-provider/commcenterd \
    components/sharing-provider/subsys_daemon components/mirroring/service.sh \
    components/refresh/post-fs-data.sh components/refresh/service.sh \
    components/refresh/pen-refresh components/native-pen/service.sh; do
    set_perm "$MODROOT/$file" 0 0 0755
done
