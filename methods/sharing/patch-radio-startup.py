#!/usr/bin/env python3
"""Guard the donor call-end notification until its delayed registration completes."""
import hashlib
import struct
import sys
from pathlib import Path

source, output = map(Path, sys.argv[1:])
original = source.read_bytes()
expected = "2758683c12ee6c5d9b68527f9e4b3592dbdf29f20de4b3d6f987eb79e6131b77"
if hashlib.sha256(original).hexdigest() != expected:
    raise SystemExit("Unexpected donor API library")

# This build's executable segment uses matching file offsets and VAs.
# Preserve the local audio focus changes, then drop only the optional remote
# notification while CommStatusTracker::registerCommEvent has yet to run.
# Reuse the debug-only logging instructions before any send buffers are created.
def branch(opcode, start, target):
    return opcode | ((target - start) // 4 << (5 if opcode == 0xB4000008 else 0))

patched = bytearray(original)
for offset, old_word, new_word in (
    (0x34C5C, 0x2A0003E2, 0xF9404288),  # ldr x8, [x20, #0x80]
    (0x34C60, 0xD0FFFF40, branch(0xB4000008, 0x34C60, 0x34DB4)),  # cbz x8, epilogue
    (0x34C64, 0x91054800, branch(0x14000000, 0x34C64, 0x34C74)),  # b send
):
    if struct.unpack_from("<I", original, offset)[0] != old_word:
        raise SystemExit(f"Unexpected instruction at {offset:#x}")
    struct.pack_into("<I", patched, offset, new_word)

output.write_bytes(patched)
print(hashlib.sha256(patched).hexdigest())
