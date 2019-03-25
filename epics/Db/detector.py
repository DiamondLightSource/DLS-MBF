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

    # PVs for user interface to bunch enable waveform
    stringOut('BUNCH_SELECT', DESC = 'Select bunch to set',
        FLNK = stringIn('SELECT_STATUS', DESC = 'Status of selection'))
    Action('SET_SELECT', DESC = 'Enable selected bunches')
    Action('RESET_SELECT', DESC = 'Disable selected bunches')

    enable = boolIn('ENABLE', 'Disabled', 'Enabled',
        DESC = 'Current detector enable state')
    updates.append(enable)

    results = [
        detector_wf('I', 'Detector I'),
        detector_wf('Q', 'Detector Q'),
        detector_wf('POWER', 'Detector Power'),
        detector_wf('PHASE', 'Detector Phase'),
        aIn('MAX_POWER', EGU = 'dB',
            DESC = 'Percentage full scale of maximum power'),
    ]
    updates.extend(results)

    # Prevent disabled detectors from generating data.  This is not strictly
    # truthful if the enable is changed while the sequencer is armed.
    for pv in results:
        pv.DISV = 0
        pv.SDIS = enable


for a in axes('DET', lmbf_mode):
    # The scale waveforms are updated separately from the other waveforms.  This
    # is necessary to reduce the network and archiver load from these waveforms,
    # which normally update quite rarely.
    Trigger('UPDATE_SCALE',
        Waveform('SCALE', DETECTOR_LENGTH, 'DOUBLE',
            DESC = 'Scale for frequency sweep'),
        Waveform('TIMEBASE', DETECTOR_LENGTH, 'LONG',
            DESC = 'Timebase for frequency sweep'),
        longIn('SAMPLES', DESC = 'Number of captured samples'))


    # Gather all the updates from the four detectors.
    updates = [
        boolIn('UNDERRUN', 'Ok', 'Underrun', OSV = 'MAJOR',
            DESC = 'Data output underrun'),
    ]
    for det in range(4):
        with name_prefix('%d' % det):
            detector_bank_pvs(updates)
    Trigger('UPDATE', *updates)


    mbbOut('SELECT', 'ADC', 'FIR', 'ADC no fill',
        DESC = 'Select detector source')
    aOut('FIR_DELAY', PREC = 1, EGU = 'turns',
        DESC = 'FIR nominal group delay')

    # This PV is something of a hack until we sort out the display
    boolOut('FILL_WAVEFORM', 'Truncated', 'Filled',
        DESC = 'Treatment of truncated waveforms')
