# Builds the out of context files for a block design

open_project edit_bd/edit_bd.xpr
set bd [get_files interconnect/interconnect.bd]

set_property target_language VHDL [current_project]
set_property synth_checkpoint_mode None $bd
generate_target all $bd

# Maybe this can go into the create_bd script.
