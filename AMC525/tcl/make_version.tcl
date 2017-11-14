# Script for building version file, run when starting synthesis.  This is
# configured as a tcl.pre hook which is run before sythesis starts

proc dirname {n path} {
    for {set i 0} {$i < $n} {incr i 1} {
        set path [file dirname $path]
    }
    return $path
}


# We need to work out where we're being called from and where our build
# directory is, then we can hand control over to the shell script to do the real
# work.
set src_dir [dirname 2 [file normalize [info script]]]
set build_dir [dirname 3 [pwd]]
set version_file "$build_dir/built/version.vhd"

# The following dance with `file mtime ...` is used to advise Vivado that
# nothing has really changed.  This approach is described as a workaround by
# Xilinx in AR# 51418 linked here:
#   https://www.xilinx.com/support/answers/51418.html
# The trick is simply to restore the version file's timestamp so Vivado doesn't
# think it has changed.  Synthesis is going rebuild *everything* anyway, so this
# really doesn't matter.
set temp_time [file mtime $version_file]

exec "$src_dir/tcl/make_version.sh" $version_file

file mtime $version_file $temp_time
