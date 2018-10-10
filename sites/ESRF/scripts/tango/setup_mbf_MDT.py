# -*- coding:utf-8 -*-

from numpy import ones

from setup_mbf_common import *
from setup_mbf_USM import MBF_HL as MBF_HL_USM
from time import sleep

#  feedback_fine_gain act on sweep too


class Cleaning():
    def __init__(self, mbf_hl):
        self.cleaning_fine_gain = None
        pass

    def init(self):
        pass
        return ""

    def clean(self, output_fct):
        raise EnvironmentError("Error: cleaning not allowed in MDT mode")

    def stop(self, output_fct):
        pass


class MBF_HL(MBF_HL_USM):
    def config_triggers(self):
        Mbf = self.Mbf
        Mbf.put('TRG:SEQ:SOFT:EN_S', 'Enable')
        Mbf.put('TRG:SEQ:SOFT:BL_S', 'All')
        Mbf.put('TRG:SEQ:MODE_S', 'Rearm')
        Mbf.put('TRG:SEQ:DELAY_S', 0)
        Mbf.gput('TRG:SOFT_S', '100 ms')

    def set_banks(self, mode, cleaning_fine_gain, feedback_fine_gain,
            sweep_bunch_enables):
        Mbf = self.Mbf
        bunch_count = Mbf.bunch_count
        all_buckets = ones(bunch_count, dtype=int)
        
        # Bank0
        Mbf.put('BUN:0:FIRWF_S', 0*all_buckets)
        Mbf.put('BUN:0:OUTWF_S', DAC_OUT_SWEEP*all_buckets)
        Mbf.put('BUN:0:GAINWF_S', feedback_fine_gain*all_buckets)

        # Bank1
        Mbf.put('BUN:1:FIRWF_S', 0*all_buckets)
        Mbf.put('BUN:1:OUTWF_S', DAC_OUT_OFF*all_buckets)
        Mbf.put('BUN:1:GAINWF_S', all_buckets)

        # Bank2
        Mbf.put('BUN:2:FIRWF_S', 0*all_buckets)
        Mbf.put('BUN:2:OUTWF_S', (DAC_OUT_FIR+DAC_OUT_SWEEP)*all_buckets)
        Mbf.put('BUN:2:GAINWF_S', feedback_fine_gain*all_buckets)

        # Bank3
        Mbf.put('BUN:3:FIRWF_S', 0*all_buckets)
        Mbf.put('BUN:3:OUTWF_S', DAC_OUT_FIR*all_buckets)
        Mbf.put('BUN:3:GAINWF_S', feedback_fine_gain*all_buckets)


    def growdamp_end(self, sweep_state=False):
        fb_state = self.get_feedback_state()
        self.comm_set_feedback_on(fb_state == 'ON')
        self.comm_set_sweep_on(sweep_state)
        self.set_param(None, 'Detector')
        self.set_param(None, 'Seq1')
        self.config_triggers()


    def growdamp_start(self, mbfGrowDampDevName):
        Mbf = self.Mbf
        mbfGrowDamp = get_device(mbfGrowDampDevName)
        str_warning = ""

        def get_attr(device, name, default_value):
            try:
                value = device.__getattr__(name)
            except AttributeError:
                value = default_value
            return value

        # get measurement parameters from mbfGrowDamp
        tune = mbfGrowDamp.Tune%1
        mode_meas_max = mbfGrowDamp.mode_meas_max
        turns_per_acq = mbfGrowDamp.turns_per_acq
        grow_turns = get_attr(mbfGrowDamp, 'grow_turns', 1)
        grow_acq_nb = get_attr(mbfGrowDamp, 'grow_acq_nb', 1)
        grow_gain = mbfGrowDamp.grow_gain
        grow_capture = mbfGrowDamp.grow_capture
        damp_acq_nb = mbfGrowDamp.damp_acq_nb
        damp_capture = mbfGrowDamp.damp_capture
        damp_feedback = mbfGrowDamp.damp_feedback
        feedback_turns = get_attr(mbfGrowDamp, 'feedback_turns', 1)
        feedback_acq_nb = get_attr(mbfGrowDamp, 'feedback_acq_nb', 1)
        feedback_capture = mbfGrowDamp.feedback_capture

        if grow_capture == 0:
            grow_dwell = grow_turns
        else:
            grow_dwell = turns_per_acq

        if feedback_capture == 0:
            feedback_dwell = feedback_turns
        else:
            feedback_dwell = turns_per_acq

        bunch_count = Mbf.bunch_count
        all_buckets = ones((bunch_count,), dtype=int)
        
        sweep_state = self.get_sweep_state()
        
        # Ensure no triggers are running and the sequencer is stopped
        Mbf.put('TRG:SEQ:DISARM_S', 0)
        Mbf.put('SEQ:RESET_S', 0)

        # Ensure super sequencer isn't in a strange state
        Mbf.put('SEQ:SUPER:RESET_S', 0)
        
        # Ensure NCO is stopped
        Mbf.put('NCO:ENABLE_S', 0)

        # Prepare Soft trig for One Shot only
        Mbf.gput('TRG:SOFT_S', 'Passive')
        Mbf.put('TRG:SEQ:MODE_S', 'One Shot')

        # Configure detector 0
        Mbf.put('DET:0:ENABLE_S', 'Enabled')
        Mbf.put('DET:0:SCALING_S', '0dB')
        Mbf.put('DET:SELECT_S', 'ADC')
        Mbf.put('DET:FIR_DELAY_S', 0)
        Mbf.put('DET:0:BUNCHES_S', all_buckets)
        Mbf.put('DET:1:ENABLE_S', 'Disabled')
        Mbf.put('DET:2:ENABLE_S', 'Disabled')
        Mbf.put('DET:3:ENABLE_S', 'Disabled')

        # SEQ0: Steady state
        # keep it as it is

        # SEQ1: Excite a mode (grow)
        Mbf.put('SEQ:3:BANK_S', 0)
        Mbf.put('SEQ:3:COUNT_S', grow_acq_nb)
        Mbf.put('SEQ:3:START_FREQ_S', tune)
        Mbf.put('SEQ:3:END_FREQ_S', tune)
        Mbf.put('SEQ:3:CAPTURE_S', grow_capture)
        Mbf.put('SEQ:3:HOLDOFF_S', 0)
        Mbf.put('SEQ:3:DWELL_S', grow_dwell)
        Mbf.put('SEQ:3:GAIN_S', grow_gain)
        Mbf.put('SEQ:3:ENWIN_S', 'Windowed')
        Mbf.put('SEQ:3:BLANK_S', 'Off')
        Mbf.put('SEQ:3:ENABLE_S', 'On')

        # SEQ2: Natural damping
        Mbf.put('SEQ:2:BANK_S', 2*damp_feedback + 1)
        # Number of points in dectector
        Mbf.put('SEQ:2:COUNT_S', damp_acq_nb)
        Mbf.put('SEQ:2:START_FREQ_S', tune)
        Mbf.put('SEQ:2:END_FREQ_S', tune)
        Mbf.put('SEQ:2:CAPTURE_S', damp_capture)
        Mbf.put('SEQ:2:HOLDOFF_S', 0)
        Mbf.put('SEQ:2:DWELL_S', turns_per_acq)
        Mbf.put('SEQ:2:GAIN_S', '0dB')
        Mbf.put('SEQ:2:ENWIN_S', 'Windowed')
        Mbf.put('SEQ:2:BLANK_S', 'Off')
        Mbf.put('SEQ:2:ENABLE_S', 'Off')

        # SEQ3: Forced damping (feedback)
        Mbf.put('SEQ:1:BANK_S', 3)
        Mbf.put('SEQ:1:COUNT_S', feedback_acq_nb)
        Mbf.put('SEQ:1:START_FREQ_S', tune)
        Mbf.put('SEQ:1:END_FREQ_S', tune)
        Mbf.put('SEQ:1:CAPTURE_S', feedback_capture)
        Mbf.put('SEQ:1:HOLDOFF_S', 0)
        Mbf.put('SEQ:1:DWELL_S', feedback_dwell)
        Mbf.put('SEQ:1:GAIN_S', '0dB')
        Mbf.put('SEQ:1:ENWIN_S', 'Windowed')
        Mbf.put('SEQ:1:BLANK_S', 'Off')
        Mbf.put('SEQ:1:ENABLE_S', 'Off')

        Mbf.put('SEQ:PC_S', 3)
        Mbf.put('SEQ:SUPER:COUNT_S', mode_meas_max)

        # Now that parameters are set, we can arm
        Mbf.put('TRG:SEQ:ARM_S', 0)

        # Wait for beam to stabilize
        sleep(0.05)

        # Wait for SEQ to be armed
        status = None
        while status != 1:
            sleep(0.05)
            status = Mbf.get('TRG:SEQ:STATUS')

        # Trig: start measurement!
        Mbf.gput('TRG:SOFT:CMD', 0)

        # Wait for SEQ to be idle
        #  -> end of measurement
        status = None
        while status != 0:
            sleep(0.05)
            status = Mbf.get('TRG:SEQ:STATUS')

        return str_warning
