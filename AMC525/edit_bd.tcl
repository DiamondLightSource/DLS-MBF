if [file isfile edit_bd/edit_bd.xpr] {
    open_project edit_bd/edit_bd.xpr
} else {
    create_project -force edit_bd edit_bd -part xc7vx690tffg1761-2
}

set_property target_language Verilog [current_project]
read_bd -quiet bd/interconnect.bd
open_bd_design bd/interconnect.bd
validate_bd_design
