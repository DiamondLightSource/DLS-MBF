from PyTango import *

def set_config(mode):
    # set PLL mode
    db = Database()
    d = db.get_property('Mfdbk', 'PLL_Device')
    PLL_device_name = d['PLL_Device'][0]
    pll_dev = DeviceProxy(PLL_device_name)
    pll_dev.Mode = mode

