# The following constraints are applied to the design after synthesis.

# Trick for false paths.  All registers matching the pattern below are generated
# by the untimed_register entity for explicitly setting a false path.
set_false_path \
    -from [get_cells -hierarchical -regexp .*false_path_register_from.*] \
    -to   [get_cells -hierarchical -regexp .*false_path_register_to.*]

# vim: set filetype=tcl:
