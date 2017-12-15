# Definition of PVs

import epicsdbbuilder
from softioc import builder


class PvSet(object):
    def __init__(self):
        self.__timestamp = 0
        self.__pvs = {}
        self.__groups = {}

    def set_timestamp(self, timestamp):
        self.__timestamp = timestamp
        for group in self.__groups.values():
            group.set_timestamp(timestamp)

    def publish(self, name, pv):
        assert name not in self.__pvs and name not in self.__groups
        pv.TSE = -2
        self.__pvs[name] = pv

    def output(self, **kargs):
        timestamp = self.__timestamp
        for key, value in kargs.items():
            self.__pvs[key].set(value, timestamp = timestamp)

    def add_group(self, name, group):
        assert isinstance(group, PvSet)
        assert name not in self.__pvs and name not in self.__groups
        self.__groups[name] = group

    def get_group(self, name):
        return self.__groups[name]

    # Make use of the PvSet slightly more friendly: expose the PVs and groups as
    # attributes, and generate a sensible attribute error if appropriate.
    def __getattr__(self, name):
        try:
            return self.__groups[name]
        except KeyError:
            try:
                pv = self.__pvs[name]
            except KeyError:
                raise AttributeError(
                    '\'%s\' object has no attribute \'%s\'' %
                        (self.__class__.__name__, name))
            else:
                return pv.get()

    # Prevent misuse by disallowing direct assignment
    def __setattr__(self, name, value):
        if name.startswith('_PvSet__'):
            super(PvSet, self).__setattr__(name, value)
        else:
            raise AttributeError(
                'Cannot write to \'%s\' attribute' % name)


# Helper for DB name prefix.
class name_prefix:
    def __init__(self, prefix):
        self.prefix = prefix
    def __enter__(self):
        epicsdbbuilder.PushPrefix(self.prefix)
    def __exit__(self, *exception):
        epicsdbbuilder.PopPrefix()


def Waveform(name, length, FTVL = 'DOUBLE'):
    return builder.Waveform(name, length = length, FTVL = FTVL)


def publish_peak_info(length, max_peaks, ratio):
    pvs = PvSet()
    with name_prefix('%d' % ratio):
        pvs.publish('power', Waveform('POWER', length))
        pvs.publish('pdd',   Waveform('PDD', length / ratio))
        pvs.publish('ix',    Waveform('IX', max_peaks, 'LONG'))
        pvs.publish('l',     Waveform('L', max_peaks, 'LONG'))
        pvs.publish('r',     Waveform('R', max_peaks, 'LONG'))
        pvs.publish('v',     Waveform('V', max_peaks))
    return pvs


def publish_model(prefix, length):
    pvs = PvSet()
    with name_prefix(prefix):
        pvs.publish('i',    Waveform('I', length))
        pvs.publish('q',    Waveform('Q', length))
        pvs.publish('p',    Waveform('P', length))
        pvs.publish('r',    Waveform('R', length))
    return pvs


def publish_config():
    def publish(build, name, pv_name, value, *args, **kargs):
        pv = build(pv_name + '_S', initial_value = value, *args, **kargs)
        pvs.publish(name, pv)

    pvs = PvSet()
    with name_prefix('CONFIG'):
        publish(builder.mbbOut, 'sel', 'SEL', 0, '/16', '/64')
        publish(builder.aOut, 'fit_threshold', 'THRESHOLD', 0.2, PREC = 2)
        publish(builder.aOut, 'max_error', 'FITERROR', 0.6, PREC = 2)
        publish(builder.aOut, 'min_width', 'MINWIDTH', 1e-6, PREC = 2)
        publish(builder.aOut, 'max_width', 'MAXWIDTH', 5e-3, PREC = 2)
    return pvs


def publish_pvs(prefix, length, max_peaks):
    pvs = PvSet()
    with name_prefix(prefix):
        pvs.publish('tune', builder.aIn('TUNE'))
        pvs.publish('power',
            builder.Waveform('POWER', length = length, FTVL = 'DOUBLE'))
        pvs.publish('scale',
            builder.Waveform('SCALE', length = length, FTVL = 'DOUBLE'))
        pvs.publish('i',
            builder.Waveform('I', length = length, FTVL = 'DOUBLE'))
        pvs.publish('q',
            builder.Waveform('Q', length = length, FTVL = 'DOUBLE'))

        pvs.add_group('peak16', publish_peak_info(length, max_peaks, 16))
        pvs.add_group('peak64', publish_peak_info(length, max_peaks, 64))

        pvs.add_group('model1', publish_model('MODEL1', length))
        pvs.add_group('model2', publish_model('MODEL2', length))

        pvs.add_group('config', publish_config())

    return pvs
