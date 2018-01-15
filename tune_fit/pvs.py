# Definition of PVs

import epicsdbbuilder
from softioc import builder


# Helper for DB name prefix.
class NamePrefix:
    def __init__(self, pvs, pv_prefix, name_prefix):
        self.pvs = pvs
        self.pv_prefix = pv_prefix
        self.name_prefix = name_prefix
    def __enter__(self):
        if self.pv_prefix:
            epicsdbbuilder.PushPrefix(self.pv_prefix)
        if self.name_prefix:
            self.pvs._push_name_prefix(self.name_prefix)
    def __exit__(self, *exception):
        if self.name_prefix:
            self.pvs._pop_name_prefix()
        if self.pv_prefix:
            epicsdbbuilder.PopPrefix()


def make_pv_builder(pv_type):
    def publish_pv(self, name, pv_name, *args, **kargs):
        pv = getattr(builder, pv_type)(pv_name, *args, **kargs)
        self.publish(name, pv)
    return publish_pv


class PvSet:
    def __init__(self):
        self.__pvs = {}
        self.__name_prefix = []

    def _push_name_prefix(self, prefix):
        self.__name_prefix.append(prefix)

    def _pop_name_prefix(self):
        self.__name_prefix.pop()

    def name_prefix(self, pv_prefix, name_prefix = None):
        return NamePrefix(self, pv_prefix, name_prefix)

    def update(self, timestamp, trace):
        for name, pv in self.__pvs.items():
            pv.set(trace._get(name), timestamp = timestamp)

    def get_config(self):
        import support
        return support.Config(3)

    def publish(self, name, pv):
        name = '.'.join(self.__name_prefix + [name])
        self.__pvs[name] = pv

    def Waveform(self, name, pv_name, length, FTVL = 'DOUBLE', **kargs):
        pv = builder.Waveform(pv_name, length = length, FTVL = FTVL, **kargs)
        self.publish(name, pv)

    boolIn = make_pv_builder('boolIn')
    aIn = make_pv_builder('aIn')
    longIn = make_pv_builder('longIn')
    mbbIn = make_pv_builder('mbbIn')


def publish_config(pvs):
    with pvs.name_prefix('CONFIG'):
        pass


def publish_tune(pvs):
    with pvs.name_prefix(None, 'tune.tune'):
        pvs.aIn('tune', 'TUNE', 0, 1, PREC = 5,
            DESC = 'Measured tune')
        pvs.aIn('phase', 'PHASE', -180, 180,
            EGU = 'deg', PREC = 1,
            DESC = 'Measured tune phase')
        pvs.aIn('synctune', 'SYNCTUNE', 0, 1, PREC = 5,
            DESC = 'Synchrotron tune')


def publish_peak(pvs, name, pv_name):
    with pvs.name_prefix(pv_name, name):
        pvs.boolIn('valid', 'VALID', 'Invalid', 'Ok',
            ZSV = 'MINOR', DESC = 'Peak valid')
        pvs.aIn('tune', 'TUNE', 0, 1, PREC = 5, DESC = 'Peak centre frequency')
        pvs.aIn('phase', 'PHASE', -180, 180, PREC = 1, EGU = 'deg',
            DESC = 'Peak phase')
        pvs.aIn('area', 'AREA', DESC = 'Peak area')
        pvs.aIn('width', 'WIDTH', 0, 1, PREC = 3, DESC = 'Peak width')
        pvs.aIn('height', 'HEIGHT', PREC = 3, DESC = 'Peak height')


def publish_delta(pvs, name, pv_name):
    with pvs.name_prefix(pv_name, name):
        pvs.aIn('tune', 'DTUNE', 0, 1, PREC = 5,
            DESC = 'Delta tune')
        pvs.aIn('phase', 'DPHASE', -180, 180, PREC = 1, EGU = 'deg',
            DESC = 'Delta phase')
        pvs.aIn('area', 'RAREA', PREC = 3, DESC = 'Relative area')
        pvs.aIn('width', 'RWIDTH', 0, 1, PREC = 3, DESC = 'Relative width')
        pvs.aIn('height', 'RHEIGHT', PREC = 3, DESC = 'Relative height')


def publish_pvs(target, length):
    pvs = PvSet()
    with pvs.name_prefix(target):
        publish_config(pvs)

        publish_tune(pvs)
        publish_peak(pvs, 'tune.left', 'LEFT')
        publish_peak(pvs, 'tune.centre', 'CENTRE')
        publish_peak(pvs, 'tune.right', 'RIGHT')
        publish_delta(pvs, 'tune.delta_left', 'LEFT')
        publish_delta(pvs, 'tune.delta_right', 'RIGHT')
    return pvs
