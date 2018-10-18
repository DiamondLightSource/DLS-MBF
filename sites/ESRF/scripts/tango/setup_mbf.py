from PyTango import *
from numpy import *
from time import *


mbfCtrl_d = {}
Mbf_d = {}

def get_mbfCtrl(mbfCtrlDevName):
    global mbfCtrl_d
    if mbfCtrlDevName not in mbfCtrl_d:
        mbfCtrl_d[mbfCtrlDevName] = DeviceProxy(mbfCtrlDevName)
    return mbfCtrl_d[mbfCtrlDevName]

def get_Mbf(mbfDevName, mbfGDevName):
    global Mbf_d
    if mbfDevName not in Mbf_d:
        Mbf_d[mbfDevName] = TangoMBF(mbfDevName, mbfGDevName)
    return Mbf_d[mbfDevName]


class TangoMBF():
    def __init__(self, mbfDevName, mbfGDevName):
        self.db = Database()
        self.mbf = DeviceProxy(mbfDevName)
        self.mbfG = DeviceProxy(mbfGDevName)
        self.lmbf_mode = self.mbfG.MODE
        if self.lmbf_mode:
            self.axis0 = self.mbfG.AXIS0
            self.axis1 = self.mbfG.AXIS1
        self.n_taps = self.mbfG.BUNCH_TAPS
        self.bunch_count = self.mbfG.BUNCHES
        self.mbfDevName = mbfDevName

    def get(pv):
        pv = pv.replace(':', '_')
        return self.mbf.__getattr__(pv)

    def put(self, pv, value):
        pv_tango = pv.replace(':', '_')
        att_config = self.mbf.get_attribute_config_ex(pv_tango)
        if att_config[0].data_type == CmdArgType.DevUShort:
            if type(value) is str:
                att_properties = self.db.get_device_attribute_property(self.mbfDevName, pv_tango)
                if pv_tango in att_properties:
                    if 'EnumLabels' in att_properties[pv_tango]:
                        value = list(att_properties[pv_tango]['EnumLabels']).index(value)
        elif att_config[0].data_type == CmdArgType.DevEnum:
            value = list(att_config[0].enum_labels).index(value)
        self.mbf.__setattr__(pv_tango, value)

    def put_axes(self, pv, value):
        if self.lmbf_mode:
            # TODO
            #_put(AXIS0, pv, value)
            #_put(AXIS1, pv, value)
            pass
        else:
            self.put(pv, value)

    def _put(self, axis, pv, value):
        pv = pv.replace(':', '_')
        if axis is None:
            self.mbfG.__setattr__(pv, value)

def compute_filter_size(tune, N_TAPS):
    # Search for best filter size.  In this search we prefer shorter filters
    # over longer filters.
    best_error = 1
    filter = (0, 0)
    for length in range(3, N_TAPS + 1):
        for cycles in range(1, length):
            error = abs(tune - float(cycles) / length)
            if error < best_error:
                best_error = error
                filter = (cycles, length)
    return filter


def gen_cleaning_pattern(sr_mode, bunch_count):
    clean_pattern = zeros((bunch_count,), dtype=int)
    if sr_mode == '7/8+1':
        gap = 61
        clean_pattern[1:1+gap] = 1
        clean_pattern[-gap:] = -1
    elif sr_mode == '16-bunch':
        for ii in range(16):
            clean_pattern[62*ii+1:62*(ii+1)] = (2*(ii%2)-1)
    elif sr_mode == '4-bunch':
        for ii in range(4):
            clean_pattern[248*ii+1:248*(ii+1)] = (2*(ii%2)-1)
    elif sr_mode == 'Hybrid':
        gap_l = 147
        gap_r = 123
        trains_l = 9
        clean_pattern[1:1+gap_l] = 1
        clean_pattern[-gap_r:] = -1
        start = gap_l+trains_l+1
        for ii in range(23):
            clean_pattern[start+ii*31:start+ii*31+(31-trains_l)] = (2*(ii%2)-1)
    elif sr_mode == 'Uniform':
        pass
    else:
        raise NameError('SR mode ' + sr_mode + ' invalid')
    return clean_pattern
