#!/usr/bin/env python3
"""Guard C15.801's optional ImsPhone callback and remote slot bounds."""
import hashlib
import io
import struct
import sys
import zipfile
import zlib
from pathlib import Path

source, output = map(Path, sys.argv[1:3])
assert sys.argv[3:] in ([], ["--slot-bounds"], ["--slot-bounds", "--signal-bounds"])
apk = bytearray(source.read_bytes())
assert hashlib.sha256(apk).hexdigest() == "e5af274500b6478a36aa1e69666596c9b6d81cc65d559b1e7b073cc54d558b3a"
with zipfile.ZipFile(io.BytesIO(apk)) as archive:
    entry = archive.getinfo("classes.dex")
    dex = bytearray(archive.read(entry))
    central = archive.start_dir
assert entry.compress_type == zipfile.ZIP_STORED and not entry.flag_bits & 8

# Reuse the debug log block for the non-null callback trampoline. Keep the
# property update, service-state notification and DMTP reply on both paths.
call = bytes.fromhex("6e1059020900")
assert dex[0x81530:0x8153A] == bytes.fromhex("1a06c8237120bf016000")
assert dex[0x8154E:0x81552] == bytes.fromhex("1f09b200")
assert dex[0x81552:0x81558] == call
dex[0x81530:0x8153A] = bytes.fromhex("2805") + call + bytes.fromhex("2810")
dex[0x81552:0x81558] = bytes.fromhex("3809030028ee")
if "--slot-bounds" in sys.argv:
    # Require 0 <= remote slot < mPhoneCount; never remap slot 1 onto slot 0.
    # Reuse the existing invalid-slot log/return block, not the state updates.
    assert dex[0x8DC20:0x8DC34] == bytes.fromhex("6000b304370508001a00d4237020911304000e00")
    dex[0x8DC24:0x8DC34] = bytes.fromhex("3b0503000e00340505000e0000000000")
if "--signal-bounds" in sys.argv:
    assert dex[0x8DADC:0x8DAF0] == bytes.fromhex("6000b304370708001a00ed1d7020911306000e00")
    dex[0x8DAE0:0x8DAF0] = bytes.fromhex("3b0703000e00340705000e0000000000")
dex[12:32] = hashlib.sha1(dex[32:]).digest()
struct.pack_into("<I", dex, 8, zlib.adler32(dex[12:]))
crc = zlib.crc32(dex)

local = entry.header_offset
assert apk[local:local + 4] == b"PK\x03\x04"
start = local + 30 + sum(struct.unpack_from("<HH", apk, local + 26))
assert apk[start:start + 8] == dex[:8]
apk[start:start + len(dex)] = dex
struct.pack_into("<I", apk, local + 14, crc)
while apk[central:central + 4] == b"PK\x01\x02":
    name, extra, comment = struct.unpack_from("<HHH", apk, central + 28)
    if apk[central + 46:central + 46 + name] == b"classes.dex":
        struct.pack_into("<I", apk, central + 16, crc)
        break
    central += 46 + name + extra + comment
else:
    raise ValueError("Missing classes.dex central entry")
with zipfile.ZipFile(io.BytesIO(apk)) as updated:
    assert updated.testzip() is None and updated.read("classes.dex") == dex
output.write_bytes(apk)
print(hashlib.sha256(apk).hexdigest())
