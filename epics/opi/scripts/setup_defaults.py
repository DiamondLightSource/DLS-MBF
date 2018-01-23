# Defaults and configuration for TMBF

harmonic = 80
bunch = 450

# Settings for basic tune measurement.
tune_threshold = 0.3
min_block_sep = 20
min_block_len = 20

# Settings for peak tune measurement
peak_smoothing = '/16'
peak_fit_threshold = 0.3
peak_max_error = 1
peak_min_width = 0
peak_max_width = 1

# Default tune selection
tune_select = 'Peak Fit'

sweep_holdoff = 0
sweep_dwell_time = 100

blanking_interval = 10000

sweep_range = 0.05
alarm_range = 0.01
tune_reverse = False            # Set to true to sweep backwards
keep_feedback = False

dac_output = 0                  # By default DAC output is off
single_bunch = False            # Set to true for single bunch mode
detector_input = 'FIR'
det_gain = '0dB'


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
FB_harmonic = 933
FB_sweep_gain = '-48dB'


# Lab setup
T_tune = 0.7885
T_harmonic = 37
T_detector_input = 'ADC'
