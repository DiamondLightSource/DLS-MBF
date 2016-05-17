# Loads a block design from script, creating a new project as necessary.
if [file isfile edit_bd/edit_bd.xpr] {
    open_project edit_bd/edit_bd.xpr
} else {
    create_project -force edit_bd edit_bd -part xc7vx690tffg1761-2
}

source [lindex $argv 0]
validate_bd_design
regenerate_bd_layout
save_bd_design
