from PyTango import *

DAC_OUT_OFF = 0
DAC_OUT_FIR = 1
DAC_OUT_NCO = 2
DAC_OUT_SWEEP = 4

mbfCtrl_d = {}
Mbf_d = {}

def get_device(mbfCtrlDevName):
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

    def get(self, pv):
        pv = pv.replace(':', '_')
        return self.mbf.__getattr__(pv)

    def _put(self, mbf_dev, pv, value):
        pv_tango = pv.replace(':', '_')
        dev_name = mbf_dev.dev_name()
        att_config = mbf_dev.get_attribute_config_ex(pv_tango)
        if att_config[0].data_type in [CmdArgType.DevUShort,
                CmdArgType.DevLong]:
            if type(value) is str:
                att_properties = self.db.get_device_attribute_property(
                        dev_name, pv_tango)
                if pv_tango in att_properties:
                    if 'EnumLabels' in att_properties[pv_tango]:
                        value = list(att_properties[pv_tango]['EnumLabels'])\
                            .index(value)
        elif att_config[0].data_type == CmdArgType.DevEnum:
            value = list(att_config[0].enum_labels).index(value)
        mbf_dev.__setattr__(pv_tango, value)

    def put(self, pv, value):
        self._put(self.mbf, pv, value)

    def gput(self, pv, value):
        self._put(self.mbfG, pv, value)

    def put_axes(self, pv, value):
        if self.lmbf_mode:
            # TODO
            #_put(AXIS0, pv, value)
            #_put(AXIS1, pv, value)
            pass
        else:
            self.put(pv, value)


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
