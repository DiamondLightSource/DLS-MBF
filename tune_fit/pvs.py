# Definition of PVs

import numpy
import epicsdbbuilder
from softioc import builder, alarm
from cothread.catools import *


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
        return pv
    return publish_in_pv


def make_config_pv_builder(pv_type, record_type):
    def publish_config_pv(self, name, *args, **kargs):
        pv = getattr(builder, pv_type)(name + '_S', *args, **kargs)
        self.publish_config_pv(name, pv, record_type)
        return pv
    return publish_config_pv


class Config:
    pass


# Computes a suitable invalid value from the given value.  Kind of tricky given
# the number of edge cases!
def invalid_value(value):
    if isinstance(value, int):
        return 0
    elif isinstance(value, str):
        return ''
    elif isinstance(value, numpy.ndarray):
        # Ok, we have a numpy array ... but alas, it might be a singleton value
        # masquerading as an array.
        if value.shape == ():
            return numpy.nan
        else:
            return numpy.empty(0)
    elif isinstance(value, float):
        # Ordinary floating point
        return numpy.nan
    elif hasattr(value, '__iter__'):
        # Iterable but not a numpy value.  Return a numpy empty value, as it
        # turns out that the Python IOC can choke if we feed a tuple back.
        return numpy.empty(0)
    else:
        # Not a clue, none of the above.  Go with what we have
        return value

def update_pv_value(trace, timestamp, pv, name):
    try:
        value = trace._get(name)
        severity = alarm.NO_ALARM
    except AttributeError:
        # Invalid value.  Compute an appropriate invalid value
        value = invalid_value(pv.get())
        severity = alarm.INVALID_ALARM
    pv.set(value, severity = severity, timestamp = timestamp)


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
            update_pv_value(trace, timestamp, pv, name)

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
            DESC = 'Reject overall fit if error too large')
        pvs.longOut('WINDOW_START', initial_value = 0,
            DESC = 'First point to fit')
        pvs.longOut('WINDOW_LENGTH', initial_value = 0,
            DESC = 'Length of window (0 means all)')


def publish_tune(pvs):
    with pvs.name_prefix(None, 'tune.tune'):
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
    pvs.aIn('fit_error', 'FIT_ERROR', PREC = 5)
    pvs.longIn('fit_length', 'FIT_LENGTH')


def publish_pvs(persist, target, length):
    pvs = PvSet(persist)
    with pvs.name_prefix(target + ':TUNE'):
        publish_config(pvs)

        pvs.aIn('max_tune', 'ATMAX', 0, 1, PREC = 5,
            DESC = 'Tune at maximum power')
        publish_tune(pvs)
        publish_peaks(pvs)
        publish_graphs(pvs, length)
        publish_info(pvs)
    return pvs


class TuneMux:
    # Selection options for tune selector mux
    SEL_FITTED = 0
    SEL_MAXIMUM = 1
    SEL_TUNE_PLL = 2

    def __init__(self, target, tune_pll, tune_aliases):
        if tune_pll:
            camonitor(tune_pll, self.update_pll, format = FORMAT_TIME)
        with NamePrefix(None, target + ':TUNE', None):
            selectors = ['Fitted', 'Maximum']
            if tune_pll:
                selectors.append('Tune PLL')
            self.selector = builder.mbbOut('SELECT_S',
                initial_value = 0, on_update = self.update_selector,
                *selectors)
            self.tune = builder.aIn('TUNE', 0, 1, PREC = 5,
                DESC = 'Measured tune')
            for alias in tune_aliases:
                self.tune.add_alias(alias)
            self.phase = builder.aIn('PHASE', -180, 180,
                EGU = 'deg', PREC = 1,
                DESC = 'Measured tune phase')

    def update_selector(self, value):
        self.tune.set(numpy.nan)
        self.phase.set(numpy.nan)

    def update(self, timestamp, trace):
        selector = self.selector.get()
        if selector == self.SEL_FITTED:
            # Use measured tune, as far as possible
            update_pv_value(trace, timestamp, self.tune, 'tune.tune.tune')
            update_pv_value(trace, timestamp, self.phase, 'tune.tune.phase')
        elif selector == self.SEL_MAXIMUM:
            # Fall back to maximum value
            update_pv_value(trace, timestamp, self.tune, 'max_tune')
            self.phase.set(numpy.nan,
                severity = alarm.INVALID_ALARM, timestamp = timestamp)

    def update_pll(self, value):
        if self.selector.get() == self.SEL_TUNE_PLL:
            self.tune.set(
                value, severity = value.severity, timestamp = value.timestamp)
            self.phase.set(
                numpy.nan, severity = alarm.INVALID_ALARM,
                timestamp = value.timestamp)
