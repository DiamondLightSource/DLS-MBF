#!/bin/bash

save_state () {
        diff -I '#.*' state `find . -iname "state_*" -print | sort | tail -n 1` > /dev/null
        if [ $? -ne 0 ]
        then
                cp state state_`date +%Y-%m-%d_%H%M`
        fi
}

cd /home/dserver/autosave/TMBF
save_state
cd /home/dserver/autosave/TFIT
save_state

