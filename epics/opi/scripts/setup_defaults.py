# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Defaults and configuration for TMBF
#  all parameters are shown in this section with a small
#  description when neeeded

# -- Tune --
# Tune value is used to:
#  - generate a suitable FIR
#  - adjust sweep for tune measurement
X_tune = 0.44
Y_tune = 0.39

# -- Feedback parameters --

# dac_out only apply to feedback and does not prevent tune measurement
# nor cleaning
dac_output = 0                  # By default Feedback is off

# -- Tune sweep --
# sweep: harmonic-sweep_range -> harmonic+sweep_range

harmonic = 80
sweep_range = 0.05
tune_reverse = False            # Set to true to sweep backwards

sweep_holdoff = 0
sweep_dwell_time = 100
sweep_gain = '-48dB'

blanking_interval = 10000
keep_feedback = False           # Set to keep feedback ON during sweep

detector_input = 'FIR'
det_gain = '0dB'

single_bunch = False            # Set to true for single bunch mode
bunch = 450

# -- Tune fit --
# The following tune fit management parameters are currently not implemented
tune_select = 'Peak Fit'
alarm_range = 0.01


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Mode specific settings

# Multibunch tune measurement
TUNE_sweep_gain = '-42dB'

# Accelerator physics mode
AP_sweep_gain = '0dB'
AP_tune = 0.25
AP_sweep_range = 0.245
AP_detector_input = 'ADC'

# Feedback on
FB_dac_output = 1               # Enable FIR output in this mode
FB_keep_feedback = True
FB_sweep_gain = '-48dB'

# Lab setup
T_tune = 0.7885
T_harmonic = 37
T_detector_input = 'ADC'
