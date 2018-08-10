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


def make_in_pv_builder(pv_type):
    def publish_in_pv(self, name, pv_name, *args, **kargs):
        pv = getattr(builder, pv_type)(pv_name, *args, **kargs)
        self.publish_in_pv(name, pv)
    return publish_in_pv


def make_config_pv_builder(pv_type, record_type):
    def publish_config_pv(self, name, *args, **kargs):
        pv = getattr(builder, pv_type)(name + '_S', *args, **kargs)
        self.publish_config_pv(name, pv, record_type)
    return publish_config_pv


class Config:
    pass


class PvSet:
    def __init__(self, persist):
        self.__persist = persist
        self.__in_pvs = {}
        self.__config_pvs = {}
        self.__name_prefix = []

    def _push_name_prefix(self, prefix):
        self.__name_prefix.append(prefix)

    def _pop_name_prefix(self):
        self.__name_prefix.pop()

    def name_prefix(self, pv_prefix, name_prefix = None):
        return NamePrefix(self, pv_prefix, name_prefix)

    def update(self, timestamp, trace):
        for name, pv in self.__in_pvs.items():
            pv.set(trace._get(name), timestamp = timestamp)

    def get_config(self):
        config = Config()
        for name, pv in self.__config_pvs.items():
            setattr(config, name, pv.get())
        return config

    def publish_in_pv(self, name, pv):
        name = '.'.join(self.__name_prefix + [name])
        self.__in_pvs[name] = pv

    def publish_config_pv(self, name, pv, type):
        self.__config_pvs[name] = pv
        self.__persist.register_pv(pv, type)

    def Waveform(self, name, pv_name, length, FTVL = 'DOUBLE', **kargs):
        pv = builder.Waveform(pv_name, length = length, FTVL = FTVL, **kargs)
        self.publish_in_pv(name, pv)

    boolIn = make_in_pv_builder('boolIn')
    aIn    = make_in_pv_builder('aIn')
    longIn = make_in_pv_builder('longIn')
    mbbIn  = make_in_pv_builder('mbbIn')
    stringIn = make_in_pv_builder('stringIn')

    aOut    = make_config_pv_builder('aOut', float)
    longOut = make_config_pv_builder('longOut', int)
    mbbOut  = make_config_pv_builder('mbbOut', int)


def publish_config(pvs):
    with pvs.name_prefix('CONFIG'):
        pvs.longOut('MAX_PEAKS', 1, 5, initial_value = 3,
            DESC = 'Maximum number of peaks to fit')
        pvs.longOut('SMOOTHING', 8, 64, initial_value = 32,
            DESC = 'Degree of smoothing for 2D peak detect')
        pvs.aOut('MINIMUM_WIDTH', 0, 1, initial_value = 1e-5, PREC = 2,
            DESC = 'Reject peaks narrower than this')
        pvs.aOut('MINIMUM_SPACING', 0, 0.5, initial_value = 1e-3, PREC = 4,
            DESC = 'Reject peaks closer than this')
        pvs.aOut('MINIMUM_HEIGHT', 0, 1, initial_value = 0.1, PREC = 3,
            DESC = 'Reject peaks shorter than this')
        pvs.aOut('MAXIMUM_FIT_ERROR', 0, 1, initial_value = 0.2, PREC = 3,
            DESC = 'Reject overall fit if error this large')


def publish_tune(pvs):
    with pvs.name_prefix('PEAK', 'tune.tune'):
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
        pvs.aIn('power', 'POWER', PREC = 3, DESC = 'Peak power')
        pvs.aIn('width', 'WIDTH', 0, 1, PREC = 3, DESC = 'Peak width')
        pvs.aIn('height', 'HEIGHT', PREC = 3, DESC = 'Peak height')


def publish_delta(pvs, name, pv_name):
    with pvs.name_prefix(pv_name, name):
        pvs.aIn('tune', 'DTUNE', 0, 1, PREC = 5,
            DESC = 'Delta tune')
        pvs.aIn('phase', 'DPHASE', -180, 180, PREC = 1, EGU = 'deg',
            DESC = 'Delta phase')
        pvs.aIn('power', 'RPOWER', PREC = 3, DESC = 'Relative power')
        pvs.aIn('width', 'RWIDTH', 0, 1, PREC = 3, DESC = 'Relative width')
        pvs.aIn('height', 'RHEIGHT', PREC = 3, DESC = 'Relative height')


def publish_peaks(pvs):
    publish_peak(pvs, 'tune.left', 'LEFT')
    publish_peak(pvs, 'tune.centre', 'CENTRE')
    publish_peak(pvs, 'tune.right', 'RIGHT')
    publish_delta(pvs, 'tune.delta_left', 'LEFT')
    publish_delta(pvs, 'tune.delta_right', 'RIGHT')


def publish_graphs(pvs, length):
    pvs.Waveform('input.scale', 'SCALE', length)
    pvs.Waveform('input.power', 'POWER', length)
    pvs.Waveform('input.iq.real', 'I', length)
    pvs.Waveform('input.iq.imag', 'Q', length)
    pvs.Waveform('output.model_power', 'MPOWER', length)
    pvs.Waveform('output.model.real', 'MI', length)
    pvs.Waveform('output.model.imag', 'MQ', length)
    pvs.Waveform('output.residue', 'RESIDUE', length)


def publish_info(pvs):
    pvs.stringIn('last_error', 'LAST_ERROR')
    pvs.aIn('output.fit_error', 'FIT_ERROR', PREC = 5)


def publish_mux(pvs, target, mux):
    pvs.mbbOut('SELECT',
        *mux.mux_options, on_update = mux.update_selection,
        initial_value = 0,
        DESC = 'Select which tune to use')
    mux.tune_pv = builder.aIn('TUNE', 0, 1,
        PREC = 5,
        DESC = 'Selected tune')
    mux.phase_pv = builder.aIn('PHASE', -180, 180,
        EGU = 'deg', PREC = 1,
        DESC = 'Selected tune phase')


def publish_pvs(persist, target, mux, length):
    pvs = PvSet(persist)
    with pvs.name_prefix(target):
        publish_config(pvs)

        publish_tune(pvs)
        publish_peaks(pvs)
        publish_graphs(pvs, length)
        publish_info(pvs)

        publish_mux(pvs, target, mux)
    return pvs
