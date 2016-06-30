#!/bin/sh

# Simple script for sanity check on DDR0 memory.
#
# Register space:
#
#   Memory generator
#
#       Read                                    Write
#       ----                                    -----
#   0   LSB initial data pattern                ditto
#   4   MSB initial data pattern                ditto
#   8   LSB data increment                      ditto
#   C   MSB data increment                      ditto
#  10                                           Write count
#
#   Debug (currently configured for AXI write capture)
#
#  780  1 => armed, 0 => ready                  Arm capture
#  784  Bits per captured row                   Reset read address
#  788  Number of rows                          Advance read address
#  790  Current readout row address
#  794  Current readout column address
#  7A0  Current readout value


cd "$(dirname "$0")"
cd ..

# Set up initial write of 0, increment of 1, as 32-bit writes
build/tools/testmem w 0 0
build/tools/testmem w 4 1
build/tools/testmem w 8 2
build/tools/testmem w 12 2
# Confirm written pattern
echo Write pattern:
build/tools/testmem r 0 16
# Arm debug capture and confirm ready
build/tools/testmem w 1920 0            # 0x780 ARM
build/tools/testmem r 1920 4            # 0x780 Should read 1
# Trigger write and confirm done
build/tools/testmem w 16 256            # 0x90 Write 256 words
echo After write:
build/tools/testmem r 1920 4            # 0x780 SHould read 0
build/tools/testmem r 128 8
build/tools/testmem r 0 32

# Read out what's in the memory
echo Memory:
dd if=/dev/amc525_lmbf.0.ddr0 count=1 |hexdump -C |head -n 2

# First few lines of write from debug
cat <<EOF
wdata            awaddr   wstrb
|                |        |  enable
|                |        |  | wlast
|                |        |  | | bresp
|                |        |  | | | awready
|                |        |  | | | | awvalid
|                |        |  | | | | | wready
|                |        |  | | | | | | wvalid
|                |        |  | | | | | | | bready
|                |        |  | | | | | | | | bvalid
|                |        |  | | | | | | | | |
EOF
build/tools/read_debug $(cat tools/debug_fields) |
head -n 20
