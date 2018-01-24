# Simple implementation of PV persistence

import atexit
import os
import traceback

import cothread

class Persistence:
    def __init__(self, config):
        self.persistence_file = config['persistence_file']
        self.persistence_interval = float(config['persistence_interval'])
        self.pvs = {}
        self.state = {}

    # Computes snapshot of current state by reading all registered pvs
    def __compute_state(self):
        state = {}
        for name, (pv, _) in self.pvs.items():
            state[name] = pv.get()
        return state

    # Loads persistent state from file.  Called at startup once PV
    # initialisation has completed
    def __load(self):
        try:
            for line in open(self.persistence_file).readlines():
                name, value = line.split('=', 1)
                if name in self.pvs:
                    pv, type = self.pvs[name]
                    pv.set(type(value))
                else:
                    print 'Unknown key', name
        except:
            print 'Unable to load', self.persistence_file
            traceback.print_exc()
        else:
            self.state = self.__compute_state()

    # Saves a new state file.  To avoid creating a half-written file, we use
    # rename after writing a temporary file.
    def __save(self, state):
        try:
            new_file = self.persistence_file + '.new'
            with open(new_file, 'w') as state_file:
                for name, value in state.items():
                    pv, _ = self.pvs[name]
                    state_file.write('%s=%s\n' % (name, pv.get()))
            os.rename(new_file, self.persistence_file)
        except:
            print 'Unable to write', self.persistence_file
            traceback.print_exc()
        else:
            self.state = state

    # Called periodically and on exit.  If the state has changed from what is in
    # the state file then update the state file.
    def check_save(self):
        state = self.__compute_state()
        if state != self.state:
            self.__save(state)

    # Periodically check whether our saved state and our internal state are in
    # step, if not write a new state file.
    def __saver(self):
        while True:
            cothread.Sleep(self.persistence_interval)
            self.check_save()

    # Registers given PV for persistent saving.
    def register_pv(self, pv, type):
        self.pvs[pv.name] = (pv, type)

    def start(self):
        self.__load()
        atexit.register(self.check_save)
        cothread.Spawn(self.__saver)
