#!/usr/bin/env python3
"""Build a PadConnect layout test artifact, not an installable APK."""

import hashlib
from io import BytesIO
from pathlib import Path
import struct
import zipfile
import zlib


ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / "PadConnect.original.apk"
OUTPUT = ROOT / "PadConnect.actual-display.test.apk"
SOURCE_SHA = "9f3c2fba2a99c3ab5c0924fe7b5efeb04a4a44901e98a540e1d3a7e74e21e22d"
DEX_NAME = "classes2.dex"


def patch_dex(dex):
    dex = bytearray(dex)
    # DisplayUtils.d(Context): do not return the cached donor stable size.
    begin, end = 0x2525DE, 0x2525F6
    if dex[begin:end] != bytes.fromhex("62008a3012016e309c0110010a003900050062048a301104"):
        raise ValueError("unexpected DisplayUtils cache fast path")
    dex[begin:end] = bytes.fromhex("280c").ljust(end - begin, b"\0")

    # Use DisplayManager.getDisplay(0).getRealSize(). The callers expect the
    # short edge in x and long edge in y and apply their own orientation.
    begin, end = 0x252610, 0x252690
    fallback = 0x2526AC  # Return the last valid Point if display is unavailable.
    if dex[begin:begin + 8] != bytes.fromhex("1c007c001a027ea7"):
        raise ValueError("unexpected DisplayUtils stable-size query")
    code = bytearray()

    def emit(raw):
        code.extend(bytes.fromhex(raw))

    def branch(opcode, register):
        offset = (fallback - begin - len(code)) // 2
        code.extend(struct.pack("<BBh", opcode, register, offset))

    emit("1200 6e20b4010400 0c04")       # v4 = displayManager.getDisplay(0)
    branch(0x38, 4)                       # if-eqz v4, fallback
    emit("22006b00 70109a010000")        # v0 = new Point()
    emit("6e20c2040400")                # v4.getRealSize(v0)
    emit("52012300 52022400")            # v1 = v0.x, v2 = v0.y
    branch(0x3D, 1)                       # if-lez v1, fallback
    branch(0x3D, 2)                       # if-lez v2, fallback
    emit("712098ec2100 0a03")            # v3 = Math.min(v1, v2)
    emit("712095ec2100 0a02")            # v2 = Math.max(v1, v2)
    emit("59032300 59022400")            # v0.x = v3, v0.y = v2
    emit("69008a30 1100")                # Save the Point; return v0.
    if len(code) > end - begin:
        raise ValueError("replacement exceeds original code range")
    dex[begin:end] = code.ljust(end - begin, b"\0")
    dex[12:32] = hashlib.sha1(dex[32:]).digest()
    struct.pack_into("<I", dex, 8, zlib.adler32(dex[12:]))
    return dex


def build(original):
    if hashlib.sha256(original).hexdigest() != SOURCE_SHA:
        raise ValueError("unexpected PadConnect source APK hash")
    with zipfile.ZipFile(BytesIO(original)) as source:
        entry = source.getinfo(DEX_NAME)
        dex = patch_dex(source.read(entry))
        # Preserve original APK offsets, alignment and native library entries.
        # These bytes no longer match the original signing block.
        output = bytearray(original)
        local = entry.header_offset
        signature, flags, method = struct.unpack_from("<4s2xHH", output, local)
        if signature != b"PK\x03\x04" or flags & 0x08 or method != zipfile.ZIP_STORED:
            raise ValueError("expected an inline, stored DEX")
        name_len, extra_len = struct.unpack_from("<HH", output, local + 26)
        data = local + 30 + name_len + extra_len
        if len(dex) != entry.file_size:
            raise ValueError("DEX size changed")
        output[data:data + len(dex)] = dex
        crc = zlib.crc32(dex)
        struct.pack_into("<I", output, local + 14, crc)

        cursor = source.start_dir
        for member in source.infolist():
            if output[cursor:cursor + 4] != b"PK\x01\x02":
                raise ValueError("unexpected central directory entry")
            if member.filename == DEX_NAME:
                struct.pack_into("<I", output, cursor + 16, crc)
                break
            cursor += 46 + sum(struct.unpack_from("<HHH", output, cursor + 28))
        else:
            raise ValueError("DEX not found in central directory")

    with zipfile.ZipFile(BytesIO(output)) as result:
        if result.read(DEX_NAME) != dex or result.testzip() is not None:
            raise ValueError("candidate ZIP readback failed")
    return output


if __name__ == "__main__":
    result = build(SOURCE.read_bytes())
    OUTPUT.write_bytes(result)
    print(hashlib.sha256(result).hexdigest(), OUTPUT.name)
