"""Use the configured Surface to decide whether to set a byte-buffer format."""

import hashlib
from pathlib import Path
import struct
import zipfile
import zlib


ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / "c15-odmf.original.jar"
OUTPUT = ROOT / "c15-odmf.surface.jar"
SOURCE_SHA = "628595d2cd39df8a47abc43c74a55232e3a4a0d92a02700821a02bcc1deb5e3d"


def main():
    if hashlib.sha256(SOURCE.read_bytes()).hexdigest() != SOURCE_SHA:
        raise ValueError("unexpected C15 ODMF source hash")
    with zipfile.ZipFile(SOURCE) as source:
        dex = bytearray(source.read("classes.dex"))
        guard = 0x590F0
        surface = 0x5910A
        if (dex[guard:guard + 8] != bytes.fromhex("548a0c07390a0900") or
                dex[surface:surface + 4] != bytes.fromhex("54831007")):
            raise ValueError("unexpected initDecodeInternal instructions")
        dex[guard + 2:guard + 4] = dex[surface + 2:surface + 4]
        dex[12:32] = hashlib.sha1(dex[32:]).digest()
        struct.pack_into("<I", dex, 8, zlib.adler32(dex[12:]))
        with zipfile.ZipFile(OUTPUT, "w") as output:
            for entry in source.infolist():
                output.writestr(entry, dex if entry.filename == "classes.dex" else source.read(entry))
    with zipfile.ZipFile(OUTPUT) as output:
        if output.testzip() is not None:
            raise ValueError("invalid patched JAR")
    print(hashlib.sha256(OUTPUT.read_bytes()).hexdigest(), OUTPUT.name)


if __name__ == "__main__":
    main()
