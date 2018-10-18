from sardana.macroserver.macro import *

from PyTango import *
import time

import setup_mbf_common


class mbf_control(Macro):
    """MultiBunch Feedback Control Sequence"""

    param_def = [['mbfDevName', Type.String, None,
                    'MBF EPICS bridge device name'],
                 ['mbfCtrlDevName', Type.String, None,
                    'MBF high level control device name'],
                 ['mbfGDevName', Type.String, None,
                    'MBF global EPICS brige device name'],
                 ['command', Type.String, None,
                    'Command to execute'],
                 ['attName', Type.String, None,
                    'Attribute changed, All or None']]
    
    def run(self, mbfDevName, mbfCtrlDevName, mbfGDevName, command, attName):
        global mbfCtrl, Mbf

        tic = time.time()
        str_warning = ""
        self.output("[mbf_%s] Start macro: %s" % (command, mbfCtrlDevName) )
        
        # reload module to handle change
        reload(setup_mbf_common)

        try:
            #mbfCtrl = DeviceProxy(mbfCtrlDevName)
            mbfCtrl = setup_mbf_common.get_device(mbfCtrlDevName)
            mbfCtrl.set_source(DevSource.DEV)
            #Mbf = setup_mbf_common.TangoMBF(mbfDevName, mbfGDevName)
            Mbf = setup_mbf_common.get_Mbf(mbfDevName, mbfGDevName)

            modeList = mbfCtrl.ModeList
            mode = modeList[mbfCtrl.mode]

            if mode[:4].lower() == 'mdt_':
                import setup_mbf_MDT as setup_mbf
                reload(setup_mbf)
                if mode[4:].lower() == 'grow_damp':
                    mbf_hl = setup_mbf.MBF_HL_GROW_DAMP(Mbf, mbfCtrl)
                elif mode[4:].lower() == 'nco1b':
                    mbf_hl = setup_mbf.MBF_HL_NCO1B(Mbf, mbfCtrl)
            else:
                import setup_mbf_USM as setup_mbf
                reload(setup_mbf)
                mbf_hl = setup_mbf.MBF_HL(Mbf, mbfCtrl)

            # Create cleaning object if necessary
            if command in ['set_param', 'clean', 'reset']:
                cleaning = setup_mbf.Cleaning(mbf_hl)
                str_warning += cleaning.init()

            if command=="on":
                mbf_hl.comm_set_feedback_on(True)

            elif command=="off" :
                mbf_hl.comm_set_feedback_on(False)

            elif command=="sweep_on":
                mbf_hl.comm_set_sweep_on(True)

            elif command=="sweep_off":
                mbf_hl.comm_set_sweep_on(False)

            elif command=="clean":
                cleaning.clean(self.output)

            elif command=="growdamp_start":
                # attName holds mbfGrowDampDevName
                mbf_hl.growdamp_start(mbfGrowDampDevName=attName)

            elif command=="growdamp_end":
                # attName holds sweep_state
                mbf_hl.growdamp_end(attName == 'ON')

            elif command=="set_param":
                self.output("setting params for: %s" % mbfCtrlDevName)
                
                sweepGainList = [0,-6,-12,-18,-24,-30,-36,-42,-48,-54,-60,
                        -66,-72,-78,-84,-90]
                firGainList = [48,42,36,30,24,18,12,6,0,-6,-12,-18,-24,-30,
                        -36,-42]

                self.output("Attriute=%s" % attName)
                self.output("Mode=%s" % mode)
                self.output("Tune=%f" % mbfCtrl.Tune)
                self.output("FeedbackGain=%d dB" %
                        firGainList[mbfCtrl.FeedbackGain])
                self.output("FeedbackFineGain=%f" % mbfCtrl.FeedbackFineGain)
                self.output("FeedbackPhase=%f" % mbfCtrl.FeedbackPhase)
                self.output("Harmonic=%f" % mbfCtrl.Harmonic)
                self.output("SweepDwellTime=%d" % mbfCtrl.SweepDwellTime)
                self.output("SweepRange=%f" % mbfCtrl.SweepRange)
                self.output("SweepGain=%d dB" %
                        sweepGainList[mbfCtrl.SweepGain])
                self.output("BlankingInterval=%d" % mbfCtrl.BlankingInterval)
                self.output("TuneOnSingleBunch=%d" % mbfCtrl.TuneOnSingleBunch)
                self.output("TuneBunch=%d" % mbfCtrl.TuneBunch)
                
                str_warning += mbf_hl.set_param(cleaning, attName)

            elif command=="reset":
                cleaning.stop(self.output)

            else:
                raise ValueError("%s %s Unknown command" %
                        (command, mbfCtrlDevName))

        except DevFailed as df:
            raise ValueError("%s %s Failed: %s" %
                    (mbfCtrlDevName, command, df[0].desc))

        self.output("[mbf_%s] End macro" % command)
        self.output("[mbf_%s] Execution time: %f s" %
                (command, time.time()-tic))

        self.warning(str_warning)
        return
        
    def on_abort(self):
        """Hook executed when an abort occurs. Overwrite as necessary"""
        self.output("[mbf_control] Abort macro")
        pass
    
    def on_pause(self):
        """Hook executed when an pause occurs. Overwrite as necessary"""
        self.output("[mbf_control] Macro is in pause mode, waiting for resume")
        pass

