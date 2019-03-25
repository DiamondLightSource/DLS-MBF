# Defaults and configuration for TMBF

harmonic = 80
bunch = 450

# Default tune selection

sweep_holdoff = 0
state_holdoff = 0
sweep_dwell_time = 100

blanking_interval = 10000

sweep_range = 0.05
tune_reverse = False            # Set to true to sweep backwards
keep_feedback = False

dac_output = 0                  # By default DAC output is off
single_bunch = False            # Set to true for single bunch mode
detector_input = 'FIR'
det_gain = '0dB'


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
AP_alarm_range = 0.245
AP_detector_input = 'ADC'
AP_min_block_len = 5

# Feedback on
FB_dac_output = 1               # Enable FIR output in this mode
FB_keep_feedback = True
FB_sweep_gain = '-48dB'


# Lab setup
T_tune = 0.7885
T_harmonic = 37
T_detector_input = 'ADC'
