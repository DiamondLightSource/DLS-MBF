# Builds the out of context files for a block design

#open_project edit_bd/edit_bd.xpr
set bd [get_files interconnect/interconnect.bd]

#set_property target_language VHDL [current_project]
# sets global run?!
reset_target all $bd
export_ip_user_files -of_objects  $bd -sync -no_script -force -quiet
delete_ip_run [get_files -of_objects [get_fileset sources_1] $bd]
set_property synth_checkpoint_mode None $bd 
generate_target all $bd
export_ip_user_files -of_objects $bd -no_script -sync -force -quiet

# Maybe this can go into the create_bd script.
