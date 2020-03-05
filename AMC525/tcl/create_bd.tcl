# Loads a block design from script, creating a new project as necessary.

set bd_name   [lindex $argv 0]
set bd_script [lindex $argv 1]

if [file isfile edit_bd/edit_bd.xpr] {
    open_project edit_bd/edit_bd.xpr
} else {
    create_project -force edit_bd edit_bd -part xc7vx690tffg1761-2
}

# Make sure the design isn't part of the project and doesn't already exist on
# disk.
if [llength [get_files */$bd_name.bd]] {
    remove_files $bd_name/$bd_name.bd
}
if [file exists $bd_name] {
    # Take one backup of the block design just for safety.
    if [file exists $bd_name.backup] {
        file delete -force $bd_name.backup
    }
    file rename $bd_name $bd_name.backup
}

source $bd_script
# Fixup incorrect address bus width assigned during import above.  This looks
# like a bug in Vivado 2019.2
set_property -dict [list CONFIG.ADDR_WIDTH {16}] [get_bd_intf_ports M_DSP_REGS]

validate_bd_design
regenerate_bd_layout
save_bd_design
