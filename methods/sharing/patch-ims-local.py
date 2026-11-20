#!/usr/bin/env python3
"""Keep the donor's local IMS initialization without publishing IImsRadio."""
import hashlib
import struct
import sys
from pathlib import Path

source, output = map(Path, sys.argv[1:])
data = bytearray(source.read_bytes())
assert hashlib.sha256(data).hexdigest() == "95f0d50af8e28604fe0f4988b0ba45fc529fddcb71a31b72d215f78022785f69"
# After QtiImsServiceSub, PadQtiImsResponse and PadQtiImsIndication init,
# jump to the existing stack-canary check and epilogue before HIDL registration.
site, epilogue = 0x2FC84, 0x2FD38
assert struct.unpack_from("<I", data, site)[0] == 0xB9801268
struct.pack_into("<I", data, site, 0x14000000 | ((epilogue - site) // 4))
output.write_bytes(data)
print(hashlib.sha256(data).hexdigest())
