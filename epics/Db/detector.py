# PVs for detectors

from common import *


def detector_wf(name, desc):
    return Waveform(name, DETECTOR_LENGTH, 'FLOAT', DESC = desc)


def detector_bank_pvs(updates):
    boolOut('ENABLE', 'Disabled', 'Enabled',
        DESC = 'Enable use of this detector')
    mbbOut('SCALING', DESC = 'Readout scaling', *dBrange(2, -8*6))

    updates.append(overflow('OUT_OVF', 'Output overflow'))

    bunch_count = longIn('COUNT', DESC = 'Number of enabled bunches')
    WaveformOut('BUNCHES', BUNCHES_PER_TURN, 'CHAR',
        FLNK = bunch_count,
        DESC = 'Enable bunches for detector')

    updates.extend([
        detector_wf('I', 'Detector I'),
        detector_wf('Q', 'Detector Q'),
        detector_wf('POWER', 'Detector Power'),
        aIn('MAX_POWER', EGU = 'dB',
            DESC = 'Percentage full scale of maximum power'),
    ])


def detector_pvs():
    updates = [
        Waveform('SCALE', DETECTOR_LENGTH, 'DOUBLE',
            DESC = 'Scale for frequency sweep'),
        Waveform('TIMEBASE', DETECTOR_LENGTH, 'LONG',
            DESC = 'Timebase for frequency sweep'),
        longIn('SAMPLES', DESC = 'Number of captured samples'),
        boolIn('UNDERRUN', 'Ok', 'Underrun', OSV = 'MAJOR',
            DESC = 'Data output underrun'),
    ]

    for det in range(4):
        with_name_prefix('%d' % det, detector_bank_pvs, updates)

    boolOut('SELECT', 'ADC', 'FIR', DESC = 'Select detector source')

    Trigger('UPDATE', *updates)


for_channels('DET', detector_pvs)
