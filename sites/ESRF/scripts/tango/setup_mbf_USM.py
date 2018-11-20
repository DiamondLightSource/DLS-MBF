from PyTango import *
from numpy import *
from time import *

import setup_mbf_common as smc
import external_devices


class Cleaning():
    def __init__(self, mbf_hl):
        self.mbf_hl = mbf_hl

    def init(self):
        Mbf = self.mbf_hl.Mbf
        str_warning = ""
        try:
            if "vertical" in Mbf.mbfDevName:
                # Get cleaning parameters
                d = Mbf.db.get_property('Mfdbk', 'Cleaning_Device')
                SRCleaning_device_name = d['Cleaning_Device'][0]
                cleaningDS = smc.get_device(SRCleaning_device_name)
                self.freq_min = cleaningDS.FreqMin
                self.freq_max = cleaningDS.FreqMax
                self.freq_sweeptime = cleaningDS.SweepTime
                self.cleaning_fine_gain = cleaningDS.Gain/100.
            else:
                self.cleaning_fine_gain = 0.
            self.init_ok = True
        except:
            self.init_ok = False
            self.cleaning_fine_gain = 0.
            str_warning += "Error while loading Cleaning parameters\n"
            str_warning += "-> SR cleaning will not be possible\n\n"
        return str_warning

    def clean(self, output_fct):
        Mbf = self.mbf_hl.Mbf
        mbfCtrl = self.mbf_hl.mbfCtrl

        if "vertical" not in Mbf.mbfDevName:
            raise ValueError(
                "Cleaning allowed only on vertical device")

        if not self.init_ok:
            raise EnvironmentError(
                "Error while loading Cleaning parameters")

        dt = 0.2

        # Stop Tune sweep during a cleaning
        Mbf.put('TRG:SEQ:DISARM_S', 0)
        Mbf.put('SEQ:RESET_S', 0)

        sweep_bunch_enables = self.mbf_hl.gen_sweep_pattern()
        feedback_fine_gain = mbfCtrl.FeedbackFineGain
        freq_min = self.freq_min
        freq_max = self.freq_max
        freq_sweeptime = self.freq_sweeptime
        modeList = mbfCtrl.ModeList
        mode = modeList[mbfCtrl.mode]
        self.mbf_hl.set_banks(mode, self.cleaning_fine_gain,
                feedback_fine_gain, sweep_bunch_enables)

        # Set Cleaning Gain
        Mbf.put('NCO:GAIN_S', '0dB')

        # Generate frequency list
        freq_list = linspace(freq_min, freq_max,
                round(freq_sweeptime/dt)-1, endpoint=True)

        # Start NCO and sweep frequency
        output_fct("Cleaning in progress, sweep from {:.6f} to {:.6f}"
                .format(freq_min,freq_max))
        Mbf.put('NCO:FREQ_S', freq_list[0])
        sleep(dt)
        Mbf.put('NCO:ENABLE_S', 1)
        for freq in freq_list:
            Mbf.put('NCO:FREQ_S', freq)
            output_fct("Cleaning in progress, currently at %.6f" % (freq))
            sleep(dt)

        # Stop NCO
        Mbf.put('NCO:ENABLE_S', 0)
        # Rearm sequence for tune sweep
        Mbf.put('TRG:SEQ:ARM_S', 0)

    def stop(self, output_fct):
        # Here we assume a cleaning is in progress, and we just have
        # to stop it
        #
        Mbf = self.mbf_hl.Mbf
        # Stop NCO
        Mbf.put('NCO:ENABLE_S', 0)
        # Rearm sequence for tune sweep
        Mbf.put('TRG:SEQ:ARM_S', 0)


def gen_cleaning_pattern(sr_mode, bunch_count):
    clean_pattern = zeros((bunch_count,), dtype=int)
    if sr_mode == '7/8+1':
        gap = 61
        clean_pattern[1:1+gap] = 1
        clean_pattern[-gap:] = -1
        # Don't clean bucket #61 to avoid killing right marker
        clean_pattern[61] = 0
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


class MBF_HL():
    def __init__(self, Mbf, mbfCtrl):
        self.Mbf = Mbf
        self.mbfCtrl = mbfCtrl

    def set_banks(self, mode, cleaning_fine_gain, feedback_fine_gain,
            sweep_bunch_enables):
        Mbf = self.Mbf
        BUNCH_COUNT = Mbf.bunch_count

        BUNCH_ONES = ones(BUNCH_COUNT, dtype = int)
        BUNCH_ZEROS = zeros(BUNCH_COUNT, dtype = int)

        # Configure banks #1, #2, #3 and #4
        #
        clean_pattern = gen_cleaning_pattern(mode, BUNCH_COUNT)

        all_bucket = ones((BUNCH_COUNT,))
        bunches = clean_pattern == 0

        outwf_fb = smc.DAC_OUT_FIR*bunches
        outwf_clean = smc.DAC_OUT_NCO*logical_not(bunches)
        outwf_sweep = smc.DAC_OUT_SWEEP*sweep_bunch_enables
        gainwf_clean = cleaning_fine_gain*clean_pattern
        gainwf_fb = feedback_fine_gain*bunches
        gainwf_fb_sweep = feedback_fine_gain*all_bucket

        # Bank1: Tune sweep
        Mbf.put('BUN:0:FIRWF_S', BUNCH_ZEROS)
        Mbf.put('BUN:0:OUTWF_S', outwf_sweep.astype(int))
        Mbf.put('BUN:0:GAINWF_S', gainwf_fb_sweep)

        # Bank2: Idle + Cleaning 
        Mbf.put('BUN:1:FIRWF_S', BUNCH_ZEROS)
        Mbf.put('BUN:1:OUTWF_S', outwf_clean.astype(int))
        Mbf.put('BUN:1:GAINWF_S', gainwf_clean)

        # Bank3: Feedback + Tune sweep
        Mbf.put('BUN:2:FIRWF_S', BUNCH_ZEROS)
        Mbf.put('BUN:2:OUTWF_S', (outwf_fb + outwf_sweep).astype(int))
        Mbf.put('BUN:2:GAINWF_S', gainwf_fb_sweep)

        # Bank4: Feedback + Cleaning
        Mbf.put('BUN:3:FIRWF_S', BUNCH_ZEROS)
        Mbf.put('BUN:3:OUTWF_S', (outwf_fb + outwf_clean).astype(int))
        Mbf.put('BUN:3:GAINWF_S', gainwf_fb + gainwf_clean)


    def gen_sweep_pattern(self):
        """Compute desired pattern for tune sweep."""
        Mbf = self.Mbf
        mbfCtrl = self.mbfCtrl
        single_bunch = mbfCtrl.TuneOnSingleBunch
        bunch = mbfCtrl.TuneBunch
        BUNCH_COUNT = Mbf.bunch_count
        sweep_bunch_enables = zeros(BUNCH_COUNT, dtype=int)
        if single_bunch:
            sweep_bunch_enables[bunch] = 1
        else:
            sweep_bunch_enables[:] = 1
        return sweep_bunch_enables


    def get_feedback_state(self):
        Mbf = self.Mbf
        seq0_bank = Mbf.get('SEQ:0:BANK_S')
        # seq1 is not a good indicator because in MDT mode it can take
        # a strange value
        if (seq0_bank == 3):
            return "ON"
        else:
            return "OFF"

    def get_sweep_state(self):
        Mbf = self.Mbf
        seq1_ena = Mbf.get('SEQ:1:ENABLE_S')
        if seq1_ena == 0:
            return "OFF"
        else:
            return "ON"

    def comm_set_feedback_on(self, state=True):
        Mbf = self.Mbf
        if state == True:
            Mbf.put('SEQ:1:BANK_S', 2)
            Mbf.put('SEQ:0:BANK_S', 3)
        else:
            Mbf.put('SEQ:1:BANK_S', 0)
            Mbf.put('SEQ:0:BANK_S', 1)

    def comm_set_sweep_on(self, state=True):
        Mbf = self.Mbf
        if state == True:
            Mbf.put('SEQ:1:ENABLE_S', 'On')
        else:
            Mbf.put('SEQ:1:ENABLE_S', 'Off')

    def config_triggers(self):
        Mbf = self.Mbf
        Mbf.put('TRG:SEQ:EXT:EN_S', 'Enable')
        Mbf.put('TRG:SEQ:EXT:BL_S', 'All')
        Mbf.put('TRG:SEQ:MODE_S', 'Rearm')
        Mbf.put('TRG:SEQ:DELAY_S', 0)

    def set_param(self, cleaning, attName):
        Mbf = self.Mbf
        mbfCtrl = self.mbfCtrl
        str_warning = ""

        modeList = mbfCtrl.ModeList
        mode = modeList[mbfCtrl.mode]
        feedback_fine_gain = mbfCtrl.FeedbackFineGain
        sweep_bunch_enables = self.gen_sweep_pattern()
        mbfDevName = Mbf.mbfDevName

        actions = []
        if attName in ['All', 'Mode', 'BlankingInterval']:
            actions += ['reset_mbf']
        if attName in ['All', 'Mode', 'FeedbackFineGain', 'TuneOnSingleBunch',
                'TuneBunch']:
            actions += ['set_banks', 'set_detector']
        if attName in ['Detector']:
            actions += ['set_detector']
        if attName in ['All', 'Mode', 'Tune']:
            actions += ['set_fir']
        if attName in ['All', 'Mode', 'FeedbackGain']:
            actions += ['set_fir_gain']
        if attName in ['All', 'Mode', 'FeedbackPhase']:
            actions += ['set_fir_phase']
        if attName in ['All', 'Mode', 'Tune', 'Harmonic', 'SweepDwellTime',
                'SweepRange', 'SweepGainAllBunches', 'Seq1']:
            actions += ['set_sweep']
        
        sweep_state = self.get_sweep_state()
        fb_state = self.get_feedback_state()
        sweep_holdoff = 0
        detector_input = 0      # Detector input is ADC (0)
        det_gain = 0            # Don't use the -48 dB scaling (0)
        
        tune_fb = mbfCtrl.Tune
        tune_sweep = mbfCtrl.Tune
        tune_reverse = False
        blanking_interval = mbfCtrl.BlankingInterval

        # Configure external devices
        # --------------------------
        if 'reset_mbf' in actions:
            reload(external_devices)
            try:
                external_devices.set_config(mode, mbfDevName)
            except ValueError:
                raise
            except:
                str_warning += "Error while calling external_device " \
                    + "(external_device.py)\n"
                str_warning += "Continue anyway...\n\n"

        # Write computed configuration
        # ----------------------------

        if 'reset_mbf' in actions:
            # First a bunch of sanity settings, in case somebody has
            # been messing with stuff.
            Mbf.put_axes('DAC:ENABLE_S', 'Off')        # Turn off while we mess with settings

            # Make sure we're sane.
            Mbf.put_axes('ADC:LOOPBACK_S', 'Normal')
            Mbf.put('SEQ:RESET_WIN_S', 0)

            # Ensure the blanking interval is right (this is not axis specific)
            Mbf.gput('TRG:BLANKING_S', blanking_interval)

            # Ensure NCO is stopped
            Mbf.put('NCO:ENABLE_S', 0)

            # Configure bank selection
            self.comm_set_feedback_on(fb_state == 'ON')
            self.comm_set_sweep_on(sweep_state == 'ON')

        if 'set_fir' in actions:
            fir_cycles, fir_length = smc.compute_filter_size(tune_fb,
                    Mbf.n_taps)
            # Configure FIR as selected
            Mbf.put('FIR:0:LENGTH_S', fir_length)
            Mbf.put('FIR:0:CYCLES_S', fir_cycles)
            Mbf.put('FIR:0:USEWF_S', 'Settings')
        if 'set_fir_phase' in actions:
            Mbf.put('FIR:0:PHASE_S', mbfCtrl.FeedbackPhase)
        if 'set_fir_gain' in actions:
            Mbf.put('FIR:GAIN_S', mbfCtrl.FeedbackGain)

        if 'set_banks' in actions:
            self.set_banks(mode, cleaning.cleaning_fine_gain,
                    feedback_fine_gain, sweep_bunch_enables)

        if 'reset_mbf' in actions:
            # Disable all sequencer triggers and configure triggering
            # on external trigger
            TRIGGER_SOURCES = ['SOFT', 'EXT', 'PM', 'ADC0', 'ADC1',
                    'SEQ0', 'SEQ1']
            for source in TRIGGER_SOURCES:
                Mbf.put('TRG:SEQ:%s:EN_S' % source, 'Ignore')
            self.config_triggers()

        if 'set_detector' in actions:
            # Configure detector 0
            Mbf.put('DET:0:ENABLE_S', 'Enabled')
            Mbf.put('DET:0:SCALING_S', det_gain)
            Mbf.put('DET:SELECT_S', detector_input)
            Mbf.put('DET:FIR_DELAY_S', 0)       # Safer than any other setting!
            Mbf.put('DET:0:BUNCHES_S', sweep_bunch_enables)

        if 'set_sweep' in actions:
            # Ensure no triggers are running and the sequencer is stopped
            Mbf.put('TRG:SEQ:DISARM_S', 0)
            Mbf.put('SEQ:RESET_S', 0)
            # Ensure super sequencer isn't in a strange state
            Mbf.put('SEQ:SUPER:COUNT_S', 1)
            Mbf.put('SEQ:SUPER:RESET_S', 0)
            # Configure sequencer for tune measurement
            Harmonic = mbfCtrl.Harmonic
            if Harmonic < 0:
                Harmonic = abs(Harmonic)
                tune_sweep += 0.5
            sweep_range = mbfCtrl.SweepRange
            sweep_start = Harmonic + tune_sweep - sweep_range
            sweep_end = sweep_start + 2 * sweep_range
            if tune_reverse:
                sweep_start, sweep_end = sweep_end, sweep_start
            Mbf.put('SEQ:1:COUNT_S', 4096)
            Mbf.put('SEQ:1:START_FREQ_S', sweep_start)
            Mbf.put('SEQ:1:END_FREQ_S', sweep_end)
            Mbf.put('SEQ:1:CAPTURE_S', 'Capture')
            Mbf.put('SEQ:1:HOLDOFF_S', sweep_holdoff)
            Mbf.put('SEQ:1:DWELL_S', mbfCtrl.SweepDwellTime)
            Mbf.put('SEQ:1:GAIN_S', mbfCtrl.SweepGainAllBunches)
            Mbf.put('SEQ:1:ENWIN_S', 'Windowed')
            Mbf.put('SEQ:1:BLANK_S', 'Blanking')

            Mbf.put('SEQ:PC_S', 1)
            # Arm has to be done after all configuration
            Mbf.put('TRG:SEQ:ARM_S', 0)

        if 'reset_mbf' in actions:
            # Now we can go!
            Mbf.put_axes('DAC:ENABLE_S', 'On')

        return str_warning
