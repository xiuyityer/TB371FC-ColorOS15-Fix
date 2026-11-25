#!/usr/bin/env python3
"""Package pinned local components without rebuilding or distributing ROM payloads."""
import argparse
import hashlib
import json
import re
import struct
from io import BytesIO
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

ROOT = Path(__file__).resolve().parent
LOCK = json.loads((ROOT / 'inputs.lock.json').read_text())
SKIP = {'customize.sh', 'module.prop', 'skip_mount', 'SHA256SUMS'}
HEX = re.compile(r'^[0-9a-f]{64}$')
IMS_LIBRARY = 'components/sharing-provider/lib64/lib-virtual-modem-qti-ims.so'


def digest(content):
    return hashlib.sha256(content).hexdigest()


def sums(files):
    return ''.join(f'{digest(data)}  {name}\n' for name, data in sorted(files.items())).encode()


def read_inputs(input_dir):
    files = {}
    for component, (relative, expected) in LOCK.items():
        path = input_dir / Path(relative).name
        if not path.is_file():
            path = input_dir / relative
        content = path.read_bytes()
        if not HEX.fullmatch(expected) or digest(content) != expected:
            raise ValueError(f'Unexpected input SHA-256: {path}')
        with ZipFile(BytesIO(content)) as archive:
            for name in archive.namelist():
                if name in SKIP or name.startswith('source/') or name.endswith(('/', '.sh')):
                    continue
                files[f'components/{component}/{name}'] = archive.read(name)
    return files


def restore_ims_registration(content):
    if digest(content) != 'ec5ec07cf6e5ee43dc23428d0ab58f7cab88654e0614db992e9a1cb417991c69':
        raise ValueError('Unexpected local-only IMS library SHA-256')
    library = bytearray(content)
    # Restore the donor's service registration and keep its stack checks and
    # cleanup. Only skip the subsequent Mindroid log call, which crashes.
    struct.pack_into('<I', library, 0x2FC84, 0xB9801268)
    struct.pack_into('<I', library, 0x2FD34, 0xD503201F)
    return bytes(library)


def package(input_dir, output_dir):
    files = read_inputs(input_dir)
    files[IMS_LIBRARY] = restore_ims_registration(files[IMS_LIBRARY])
    template = ROOT / 'module'
    for path in template.rglob('*'):
        if path.is_file() and (path.suffix in {'.sh', '.xml'} or path == template / 'module.prop'):
            files[path.relative_to(template).as_posix()] = path.read_bytes()
    provider = 'components/sharing-provider/'
    files[provider + 'SHA256SUMS'] = sums({name.removeprefix(provider): data for name, data in files.items()
                                         if name.startswith(provider)})
    files['skip_mount'] = b''
    files['SHA256SUMS'] = sums(files)
    output_dir.mkdir(parents=True, exist_ok=True)
    version = next(line.split('=', 1)[1] for line in files['module.prop'].decode().splitlines()
                   if line.startswith('version='))
    output = output_dir / f'kayu-coloros15-fix-{version}.zip'
    temporary = output.with_suffix('.tmp')
    with ZipFile(temporary, 'w', ZIP_DEFLATED) as archive:
        for name, data in sorted(files.items()):
            entry = ZipInfo(name, (2026, 11, 20, 0, 0, 0))
            mode = 0o755 if name.endswith('.sh') or Path(name).name in {'commcenterd', 'subsys_daemon', 'pen-refresh'} else 0o644
            entry.external_attr = (0o100000 | mode) << 16
            archive.writestr(entry, data, compress_type=ZIP_DEFLATED)
    with ZipFile(temporary) as archive:
        if (bad := archive.testzip()) is not None:
            raise ValueError(f'Corrupt ZIP entry: {bad}')
    temporary.replace(output)
    output.with_suffix('.sha256').write_bytes(sums({output.name: output.read_bytes()}))
    return output


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--inputs', type=Path, default=ROOT / 'inputs', help='pinned ZIP directory or workspace worklog/runs')
    parser.add_argument('--out', type=Path, default=ROOT / 'dist')
    args = parser.parse_args()
    try:
        print(package(args.inputs, args.out))
    except (OSError, ValueError) as error:
        parser.exit(1, f'{error}\n')
