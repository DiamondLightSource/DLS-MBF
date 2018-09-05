#!/bin/bash

save_state () {
	diff state `find . -iname "state_*" -print | sort | tail -n 1` > /dev/null
	if [ $? -ne 0 ]
	then
		cp state state_`date +%Y-%m-%d_%H%M`
	fi
}

cd /users/dserver/autosave/SR-TMBF
save_state
cd /users/dserver/autosave/SR-TFIT
save_state
