# PVs for detectors

from common import *

DETECTOR_LENGTH = Parameter('DETECTOR_LENGTH', 'Detector readout length')

def detector_wf(name, desc):
    return Waveform(name, DETECTOR_LENGTH, 'FLOAT', DESC = desc)


def detector_bank_pvs(updates):
    boolOut('ENABLE', 'Disabled', 'Enabled',
        DESC = 'Enable use of this detector')
    mbbOut('SCALING', DESC = 'Readout scaling',
        *['2^-%d' % (8 * n) for n in range(8)])

    updates.extend([
        overflow('FIR_OVF', 'FIR input overflow'),
        overflow('OUT_OVF', 'Output overflow'),
        boolIn('UNDERRUN', 'Ok', 'Underrun', OSV = 'MAJOR',
            DESC = 'Data output underrun')])

    WaveformOut('BUNCHES', BUNCHES_PER_TURN, 'CHAR',
        DESC = 'Enable bunches for detector')

    updates.extend([
        detector_wf('I', 'Detector I'),
        detector_wf('Q', 'Detector Q'),
        detector_wf('POWER', 'Detector Power'),
    ])


def detector_pvs():
    updates = []
    for det in range(4):
        with_name_prefix('%d' % det, detector_bank_pvs, updates)

    boolOut('FIR_GAIN', 'High', 'Low', DESC = 'Select FIR gain')
    boolOut('SELECT', 'ADC', 'FIR', DESC = 'Select detector source')

    boolIn('UPDATE',
        FLNK = create_fanout('UPDATE:FAN', *updates),
        SCAN = 'I/O Intr',
        DESC = 'Update detector PVs on scan completion')


for_channels('DET', detector_pvs)
