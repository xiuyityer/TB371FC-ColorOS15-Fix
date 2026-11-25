#!/usr/bin/env python3
"""Host-side checks; Android services and KSU callbacks are simulated."""
import argparse
import os
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory
from xml.etree import ElementTree
from zipfile import ZipFile

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from build import IMS_LIBRARY, LOCK, digest, package, sums

MOCK = '''
getprop() {
    case "$1" in
        ro.product.board) echo 'another-board' ;;
        ro.boot.slot_suffix) echo '_b' ;;
        ro.build.fingerprint) echo 'test/other/other:15/test:test' ;;
    esac
}
uname() { case "$1" in -r) echo '6.6.1-test';; -v) echo '#1 SMP';; esac; }
getenforce() { echo Permissive; }
abort() { echo "$*"; exit 101; }
set_perm_recursive() { [ "$(pwd)" != / ] && [ "$1" = "$MODPATH" ]; }
set_perm() { chmod "$4" "$1"; }
sha256sum() { shasum -a 256 "$@"; }
'''


def verify_zip(path, input_dir, root):
    with ZipFile(path) as archive:
        assert archive.testzip() is None
        assert len(set(archive.namelist())) == len(archive.namelist())
        assert all(not name.startswith('/') and '..' not in Path(name).parts for name in archive.namelist())
        assert not any(name.startswith('system/') for name in archive.namelist())
        contents = {name: archive.read(name) for name in archive.namelist()}
        assert contents.pop('SHA256SUMS') == sums(contents)
        assert contents['skip_mount'] == b''
        props = dict(line.split('=', 1) for line in contents['module.prop'].decode().splitlines())
        assert (props['id'], props['name'], props['version'], props['versionCode'], props['author']) == (
            'kayu_coloros15_fix', '卡鱼 coloros15 综合修复', 'v1.0.2-beta.8-ims', '109', 'xiuyityer')
        declaration = 'components/sharing-declarations/system/etc/permissions/c15-virtual-telephony.xml'
        features = ElementTree.fromstring(contents[declaration])
        assert {elem.attrib['name'] for elem in features.findall('feature')} == {
            'android.hardware.telephony.calling',
            'android.hardware.telephony.messaging', 'android.hardware.telephony.ims',
        }
        provider_prefix = 'components/sharing-provider/'
        provider = {name.removeprefix(provider_prefix): data for name, data in contents.items()
                    if name.startswith(provider_prefix)}
        assert provider.pop('SHA256SUMS') == sums(provider)
        archive.extractall(root)
    ims_manifest = 'components/sharing-declarations/vintf/c15-virtual-provider.xml'
    manifest = ElementTree.fromstring(contents[ims_manifest])
    ims = manifest.find("./hal/[name='vendor.qti.hardware.radio.ims']")
    assert ims.attrib['format'] == 'hidl'
    assert ims.findtext('version') == '1.7'
    assert ims.findtext('interface/name') == 'IImsRadio'
    assert ims.findtext('interface/instance') == 'imsradio0'
    assert digest(contents[IMS_LIBRARY]) == 'b8fe6a3b85f68ebfde070cea701c9fea15ce5a744e89066608998e80cc6e899b'
    count = 0
    for component, (relative, expected) in LOCK.items():
        path = input_dir / Path(relative).name
        if not path.is_file():
            path = input_dir / relative
        assert digest(path.read_bytes()) == expected
        with ZipFile(path) as source:
            for name in source.namelist():
                if name.endswith(('.sh', '/')) or name in {'module.prop', 'SHA256SUMS', 'skip_mount'} or name.startswith('source/'):
                    continue
                key = f'components/{component}/{name}'
                if key in {IMS_LIBRARY, ims_manifest}:
                    continue
                assert contents[key] == source.read(name), name
                count += 1
    print(f'ZIP, metadata, both checksum lists, IMS entries, and {count} unchanged payloads: OK')
    for script in root.rglob('*.sh'):
        subprocess.run(['sh', '-n', str(script)], check=True)
        content = script.read_text()
        for guard in ('ro.serialno', 'ro.product.', 'ro.boot.slot_suffix', 'ro.build.fingerprint',
                      'uname -r', 'uname -v', 'getenforce'):
            assert guard not in content, (script, guard)
    print('Shell syntax and absence of hardcoded device and kernel guards: OK')


def verify_hooks(root, temp):
    stash = temp / 'device'
    fixture = temp / 'fixture.sh'
    common = root / 'common.sh'
    original = common.read_text()
    env = dict(os.environ, MODPATH=str(root), BOOTMODE='true', TRACE=str(temp / 'trace'))

    def hook(name, expected=0, text=None, **add_env):
        if name == 'customize.sh':
            command = '. "$1"; . "$2"; test "$SKIPMOUNT" = true'
        else:
            command = '. "$1"; . "$2"'
        proc = subprocess.run(['bash', '-c', command, str(root / name), str(fixture), str(root / name)],
                              cwd=root, env=dict(env, **add_env), capture_output=True, text=True, timeout=12)
        assert proc.returncode == expected, (name, proc.returncode, proc.stdout, proc.stderr)
        if text:
            assert text in proc.stdout, (name, proc.stdout, proc.stderr)

    # Preserve the real manifest while representing /data/adb in a temporary directory.
    # Only this copy of the hooks is used below; device scripts are never executed locally.
    fixture.write_text(MOCK + f'\nADB_TEST_ROOT={stash}\n')
    common.write_text(original.replace('ADB_ROOT=/data/adb', 'ADB_ROOT=$ADB_TEST_ROOT'))
    sums_path = root / 'SHA256SUMS'
    members = [line.split('  ', 1)[1] for line in sums_path.read_text().splitlines()]
    sums_path.write_bytes(sums({name: (root / name).read_bytes() for name in members}))
    legacy = stash / 'modules/c15_refresh_pen'
    legacy.mkdir(parents=True)
    hook('customize.sh', 101, 'Disable the five legacy')
    (legacy / 'disable').touch()
    pending = stash / 'modules_update/c15_native_pen'
    pending.mkdir(parents=True)
    hook('customize.sh', 101, 'pending updates')
    pending.rmdir()
    hook('customize.sh', 101, 'Install from KernelSU', BOOTMODE='false')
    hook('customize.sh')
    assert os.access(root / 'components/refresh/pen-refresh', os.X_OK)
    module_prop = root / 'module.prop'
    module_prop.write_bytes(module_prop.read_bytes() + b'# tampered\n')
    hook('customize.sh', 101, 'integrity check failed')
    print('Installer: alternate device properties accepted; recovery, legacy/pending modules and tampering rejected')

    for name in ('sharing-declarations', 'refresh'):
        child = root / f'components/{name}/post-fs-data.sh'
        child.write_text(f'echo {name} >>"$TRACE"\nexit {7 if name == "sharing-declarations" else 0}\n')
    trace = Path(env['TRACE'])
    hook('post-fs-data.sh', 1)
    assert trace.read_text().splitlines() == ['sharing-declarations', 'refresh']
    assert 'sharing-declarations rc=7' in (root / 'early.log').read_text()
    trace.unlink()
    (root / 'disable').touch()
    hook('post-fs-data.sh')
    hook('service.sh')
    assert not trace.exists()
    (root / 'disable').unlink()
    (legacy / 'disable').unlink()
    hook('post-fs-data.sh', 1)
    hook('service.sh', 1)
    assert not trace.exists()
    (legacy / 'disable').touch()
    for name in ('sharing-provider', 'refresh', 'mirroring', 'native-pen'):
        child = root / f'components/{name}/service.sh'
        preamble = '[ "$C15_MODULE_ROOT" = "$MODPATH" ] || exit 9\n'
        body = f'echo {name} >>"$TRACE"\n'
        if name in {'sharing-provider', 'refresh'}:
            # A serial scheduler would never reach native-pen and would time out here.
            body += 'for i in 1 2 3 4 5; do\n  [ ! -f "$TRACE.done" ] || exit 0\n  sleep 1\ndone\nexit 8\n'
        if name == 'mirroring':
            body += 'exit 6\n'
        if name == 'native-pen':
            body += 'touch "$TRACE.done"\n'
        child.write_text(preamble + body)
    hook('service.sh')
    assert sorted(trace.read_text().splitlines()) == ['mirroring', 'native-pen', 'refresh', 'sharing-provider']
    assert 'mirroring exited rc=6' in (root / 'late.log').read_text()
    print('Boot dispatch: early order, failure isolation, disable/conflict guards, nonblocking late workers: OK')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('zip', type=Path)
    parser.add_argument('--inputs', type=Path, required=True)
    args = parser.parse_args()
    with TemporaryDirectory(prefix='kayu-c15-test-') as directory:
        temp = Path(directory)
        root = temp / 'extracted'
        verify_zip(args.zip, args.inputs, root)
        verify_hooks(root, temp)
        rebuilt = package(args.inputs, temp / 'rebuilt')
        assert digest(rebuilt.read_bytes()) == digest(args.zip.read_bytes())
        print('Independent repeat build: byte-identical ZIP, SHA-256 ' + digest(rebuilt.read_bytes()))
