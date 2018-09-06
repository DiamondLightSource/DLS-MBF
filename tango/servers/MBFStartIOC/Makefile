mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
project_name:=$(current_dir)
py_directory=/operation/dserver/python/modules
bin_directory=/operation/dserver/$$ostype/bin

all: $(project_name)_debian6 $(project_name)_debian7 $(project_name)_debian8 $(project_name)_debian9

$(project_name)_debian6 $(project_name)_debian7 $(project_name)_debian8 $(project_name)_debian9: $(project_name).py
		sed -e 's#(PY_DIRECTORY)#$(py_directory)#g' -e 's#(PROJECT_NAME)#$(project_name)#g' -e "s#(OS_TYPE)#$(subst $(project_name)_,,$@)#g" run_script.template > $@ ;\

install: all
	install -m 0755 $(project_name).py $(py_directory)/
	for ostype in debian6 debian7 debian8 debian9; do \
		install -m 0755 $(project_name)_$$ostype $(bin_directory)/$(project_name) ;\
	done

clean:
	rm -f $(project_name)_debian6 $(project_name)_debian7 $(project_name)_debian8 $(project_name)_debian9

.PHONY: install all clean
