#!/usr/bin/python3
import argparse

def strip(num_sections, infile, outfile):
    data = bytearray(infile.read())

    pe_offset = int.from_bytes(data[0x3C:0x40], byteorder="little", signed=False)
    data[pe_offset+6:pe_offset+8] = num_sections.to_bytes(2, byteorder="little")

    outfile.write(data)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Strip extra sections from PE/EFI binaries")
    parser.add_argument(
        "--num-sections",
        type=int,
        default=6,
        help="Number of sections to keep",
    )
    parser.add_argument(
        "IN",
        type=argparse.FileType("rb"),
        help="Input PE/EFI file",
    )
    parser.add_argument(
        "OUT",
        type=argparse.FileType("wb"),
        help="Output PE/EFI file",
    )
    args = parser.parse_args()
    strip(args.num_sections, args.IN, args.OUT)
