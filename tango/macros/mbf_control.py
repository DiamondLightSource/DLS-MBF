from sardana.macroserver.macro import *

from PyTango import *
from numpy import *
from time import *

import setup_mbf
import external_devices


DAC_OUT_FIR = 1
DAC_OUT_NCO = 2
DAC_OUT_SWEEP = 4

def set_banks(Mbf, mode, cleaning_fine_gain, feedback_fine_gain, BUNCH_ENABLES):
    BUNCH_COUNT = Mbf.bunch_count

    BUNCH_ONES = ones(BUNCH_COUNT, dtype = int)
    BUNCH_ZEROS = zeros(BUNCH_COUNT, dtype = int)

    # Configure banks #1, #2, #3 and #4
    #
    clean_pattern = setup_mbf.gen_cleaning_pattern(mode, BUNCH_COUNT)

    all_bucket = ones((BUNCH_COUNT,))
    bunches = clean_pattern == 0

    outwf_fb = DAC_OUT_FIR*bunches
    outwf_clean = DAC_OUT_NCO*logical_not(bunches)
    outwf_sweep = DAC_OUT_SWEEP*BUNCH_ENABLES
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


class mbf_control(Macro):
    """MultiBunch Feedback Control Sequence"""

    param_def  = [ [ 'mbfDevName',  Type.String, None, 'MBF EPICS bridge device name'],
                   [ 'mbfCtrlDevName',  Type.String, None, 'MBF high level control device name'],
                   [ 'mbfGDevName',  Type.String, None, 'MBF global EPICS brige device name'],
                   [ 'command',  Type.String, None, 'Command to execute'],
                   [ 'attName',  Type.String, None, 'Attribute changed, All or None'], ]
    
    def run(self, mbfDevName, mbfCtrlDevName, mbfGDevName, command, attName):
        global mbfCtrl, Mbf

        tic = time()
        self.output("[mbf_%s] Start macro: %s" % (command, mbfCtrlDevName) )
        
        # reload module to handle change
        #reload(setup_mbf)

        try:

            #mbfCtrl = DeviceProxy(mbfCtrlDevName)
            mbfCtrl = setup_mbf.get_mbfCtrl(mbfCtrlDevName)
            mbfCtrl.set_source(DevSource.DEV)
            #Mbf = setup_mbf.TangoMBF(mbfDevName, mbfGDevName)
            Mbf = setup_mbf.get_Mbf(mbfDevName, mbfGDevName)
            db = Database()

            modeList = mbfCtrl.ModeList
            mode = modeList[mbfCtrl.mode]
            single_bunch = mbfCtrl.TuneOnSingleBunch
            bunch = mbfCtrl.TuneBunch

	    # Compute desired pattern for tune sweep.
	    BUNCH_COUNT = Mbf.bunch_count
	    BUNCH_ENABLES = zeros(BUNCH_COUNT, dtype = int)
	    if single_bunch:
		BUNCH_ENABLES[bunch] = 1
	    else:
		BUNCH_ENABLES[:] = 1

            if command=="on" :

                Mbf.put('SEQ:1:BANK_S', 2)
                Mbf.put('SEQ:0:BANK_S', 3)

            elif command=="off" :

                Mbf.put('SEQ:1:BANK_S', 0)
                Mbf.put('SEQ:0:BANK_S', 1)

            elif command=="sweep_on":

                Mbf.put('SEQ:1:ENABLE_S', 'On')
                
            elif command=="sweep_off":

                Mbf.put('SEQ:1:ENABLE_S', 'Off')

            elif command=="clean":

                if "vertical" not in mbfDevName:
                    raise ValueError("Cleaning allowed only on vertical device")

                d = db.get_property('Mfdbk', 'Cleaning_Device')
                SRCleaning_device_name = d['Cleaning_Device'][0]
                
                # Get cleaning parameters
                cleaningDS = DeviceProxy(SRCleaning_device_name);
                freq_min = cleaningDS.FreqMin
                freq_max = cleaningDS.FreqMax
                freq_sweeptime = cleaningDS.SweepTime
                cleaning_fine_gain = cleaningDS.Gain/100.
                dt = 0.2

                feedback_fine_gain = mbfCtrl.FeedbackFineGain
                
                # Stop Tune sweep during a cleaning
                Mbf.put('TRG:SEQ:DISARM_S', 0)
                Mbf.put('SEQ:RESET_S', 0)

                set_banks(Mbf, mode, cleaning_fine_gain, feedback_fine_gain, BUNCH_ENABLES)

                # Set Cleaning Gain
                Mbf.put('NCO:GAIN_S', '0dB')

                # Generate frequency list
                freq_list = linspace(freq_min, freq_max, round(freq_sweeptime/dt)-1, endpoint=True)

                # Start NCO and sweep frequency
                self.output("Cleaning in progress, sweep from %.6f to %.6f " % (freq_min,freq_max))
                Mbf.put('NCO:FREQ_S', freq_list[0])
                sleep(dt)
                Mbf.put('NCO:ENABLE_S', 1)
                for freq in freq_list:
                    Mbf.put('NCO:FREQ_S', freq)
                    self.output("Cleaning in progress, currently at %.6f" % (freq))
                    sleep(dt)

                # Stop NCO
                Mbf.put('NCO:ENABLE_S', 0)
                # Rearm sequence for tune sweep
                Mbf.put('TRG:SEQ:ARM_S', 0)

            elif command=="set_param":

                self.output("setting params for: %s" % mbfCtrlDevName);
                
                sweepGainList = [0,-6,-12,-18,-24,-30,-36,-42,-48,-54,-60,-66,-72,-78,-84,-90]
                firGainList = [48,42,36,30,24,18,12,6,0,-6,-12,-18,-24,-30,-36,-42]

                self.output("Attriute=%s" % attName)
                self.output("Mode=%s" % mode)
                self.output("Tune=%f" % mbfCtrl.Tune)
                self.output("FeedbackGain=%d dB" % firGainList[mbfCtrl.FeedbackGain])
                self.output("FeedbackFineGain=%f" % mbfCtrl.FeedbackFineGain)
                self.output("FeedbackPhase=%f" % mbfCtrl.FeedbackPhase)
                self.output("Harmonic=%f" % mbfCtrl.Harmonic)
                self.output("SweepDwellTime=%d" % mbfCtrl.SweepDwellTime)
                self.output("SweepRange=%f" % mbfCtrl.SweepRange)
                self.output("SweepGain=%d dB" % sweepGainList[mbfCtrl.SweepGain])
                self.output("BlankingInterval=%d" % mbfCtrl.BlankingInterval)
                self.output("TuneOnSingleBunch=%d" % mbfCtrl.TuneOnSingleBunch)
                self.output("TuneBunch=%d" % mbfCtrl.TuneBunch)
                
                actions = []
                if attName in ['All', 'BlankingInterval']:
                    actions += ['reset_mbf']
                if attName in ['All', 'Mode', 'FeedbackFineGain',
                        'TuneOnSingleBunch', 'TuneBunch']:
                    actions += ['set_banks']
                if attName in ['All', 'Tune']:
                    actions += ['set_fir']
                if attName in ['All', 'FeedbackGain']:
                    actions += ['set_fir_gain']
                if attName in ['All', 'FeedbackPhase']:
                    actions += ['set_fir_phase']
                if attName in ['All', 'Tune', 'Harmonic', 'SweepDwellTime',
                        'SweepRange', 'SweepGain']:
                    actions += ['set_sweep']
                
                sweep_status = mbfCtrl.SweepState == DevState.ON
                feedback_status = mbfCtrl.State() == DevState.ON
                sweep_holdoff = 0
                detector_input = 0      # Detector input is ADC (0)
                det_gain = 0            # Don't use the -48 dB scaling (0)
                cleaning_fine_gain = 0.0
                
                tune_fb = mbfCtrl.Tune
                tune_sweep = mbfCtrl.Tune
                tune_reverse = False
                feedback_fine_gain = mbfCtrl.FeedbackFineGain
                blanking_interval = mbfCtrl.BlankingInterval
                N_TAPS = Mbf.n_taps

                # Configure external devices
                # --------------------------
                if 'reset_mbf' in actions:
                    try:
                        external_devices.set_config(mode)
                    except:
                        self.warning("Error while calling external_device (external_device.py)")
                        self.warning("Continue anyway...")

                # ------------------------------------------------------------------------------
                # Write computed configuration

                if 'reset_mbf' in actions:
                    # First a bunch of sanity settings, in case somebody has been messing with
                    # stuff.
                    Mbf.put_axes('DAC:ENABLE_S', 'Off')        # Turn off while we mess with settings

                    # Make sure we're sane.
                    Mbf.put_axes('ADC:LOOPBACK_S', 'Normal')
                    Mbf.put('SEQ:RESET_WIN_S', 0)

                    # Ensure no triggers are running and the sequencer is stopped
                    Mbf.put('TRG:SEQ:DISARM_S', 0)
                    Mbf.put('SEQ:RESET_S', 0)

                    # Ensure super sequencer isn't in a strange state
                    Mbf.put('SEQ:SUPER:COUNT_S', 1)
                    Mbf.put('SEQ:SUPER:RESET_S', 0)

                    # Ensure the blanking interval is right (this is not axis specific)
                    Mbf._put(None, 'TRG:BLANKING_S', blanking_interval)

                    # Ensure NCO is stopped
                    Mbf.put('NCO:ENABLE_S', 0)

                    # Configure bank selection
                    if feedback_status:
                        Mbf.put('SEQ:1:BANK_S', 2)
                        Mbf.put('SEQ:0:BANK_S', 3)
                    else:
                        Mbf.put('SEQ:1:BANK_S', 0)
                        Mbf.put('SEQ:0:BANK_S', 1)

                if 'set_fir' in actions:
                    fir_cycles, fir_length = setup_mbf.compute_filter_size(
                            tune_fb, N_TAPS)
                    # Configure FIR as selected
                    Mbf.put('FIR:0:LENGTH_S', fir_length)
                    Mbf.put('FIR:0:CYCLES_S', fir_cycles)
                    Mbf.put('FIR:0:USEWF_S', 'Settings')
                if 'set_fir_phase' in actions:
                    Mbf.put('FIR:0:PHASE_S', mbfCtrl.FeedbackPhase)
                if 'set_fir_gain' in actions:
                    Mbf.put('FIR:GAIN_S', mbfCtrl.FeedbackGain)

                if 'set_banks' in actions:
                    set_banks(Mbf, mode, cleaning_fine_gain, feedback_fine_gain, BUNCH_ENABLES)

                if 'reset_mbf' in actions:
                    # Disable all sequencer triggers and configure triggering on external trigger
                    TRIGGER_SOURCES = ['SOFT', 'EXT', 'PM', 'ADC0', 'ADC1', 'SEQ0', 'SEQ1']
                    for source in TRIGGER_SOURCES:
                        Mbf.put('TRG:SEQ:%s:EN_S' % source, 'Ignore')
                    Mbf.put('TRG:SEQ:EXT:EN_S', 'Enable')
                    Mbf.put('TRG:SEQ:EXT:BL_S', 'All')
                    Mbf.put('TRG:SEQ:MODE_S', 'Rearm')
                    Mbf.put('TRG:SEQ:DELAY_S', 0)

                if 'set_banks' in actions:
                    # Configure detector 0
                    Mbf.put('DET:0:ENABLE_S', 'Enabled')
                    Mbf.put('DET:0:SCALING_S', det_gain)
                    Mbf.put('DET:SELECT_S', detector_input)
                    Mbf.put('DET:FIR_DELAY_S', 0)       # Safer than any other setting!
                    Mbf.put('DET:0:BUNCHES_S', BUNCH_ENABLES)

                if 'set_sweep' in actions:
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
                    Mbf.put('SEQ:1:GAIN_S', mbfCtrl.SweepGain)
                    Mbf.put('TRG:SEQ:ARM_S', 0)
                    Mbf.put('SEQ:1:ENWIN_S', 'Windowed')
                    Mbf.put('SEQ:1:BLANK_S', 'Blanking')

                    Mbf.put('SEQ:PC_S', 1)

                if 'reset_mbf' in actions:
                    # Now we can go!
                    Mbf.put_axes('DAC:ENABLE_S', 'On')

                    if sweep_status:
                        Mbf.put('SEQ:1:ENABLE_S', 'On')
                    else:
                        Mbf.put('SEQ:1:ENABLE_S', 'Off')
                
                
                

            elif command=="reset":
                # Here we assume a cleaning was in progress, and we just have to stop it
                # Stop NCO
                Mbf.put('NCO:ENABLE_S', 0)
                # Rearm sequence for tune sweep
                Mbf.put('TRG:SEQ:ARM_S', 0)

            else:
                raise ValueError("%s %s Unknown command" % (command, mbfCtrlDevName))

        except DevFailed as df:
            raise ValueError("%s %s Failed: %s" % (mbfCtrlDevName, command, df[0].desc))

        self.output("[mbf_%s] End macro" % command)
        self.output("[mbf_%s] Execution time: %f s" % (command, time()-tic) )
        return
        
    def on_abort(self):
        """Hook executed when an abort occurs. Overwrite as necessary"""
        self.output("[mbf_control] Abort macro")
        pass
    
    def on_pause(self):
        """Hook executed when an pause occurs. Overwrite as necessary"""
        self.output ("[mbf_control] Macro is in pause mode, waiting for resume")
        pass

