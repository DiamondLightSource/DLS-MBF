# The constraints in this file are not applied during synthesis, only during
# implementation.


# The following code is to work around a problem with generated block rams.
# For reasons only known to Xilinx, inferred block rams are often synthesised
# with the write mode on each port set to READ_FIRST, which unfortunately makes
# the memory too slow for 500 MHz operation.
#   As we *never* need this mode of operation (I don't actually ever read and
# write from the same port), let's just force bram blocks into WRITE_FIRST mode.
#   Also take care not to apply this hack to the blocks in the interconnect, as
# we don't know what assumptions are made in this code.
set memory_blocks [get_cells -hierarchical -regexp -filter \
    {PRIMITIVE_SUBGROUP == bram && NAME !~ interconnect_inst/.*}]
set_property WRITE_MODE_A WRITE_FIRST $memory_blocks
set_property WRITE_MODE_B WRITE_FIRST $memory_blocks

# vim: set filetype=tcl: