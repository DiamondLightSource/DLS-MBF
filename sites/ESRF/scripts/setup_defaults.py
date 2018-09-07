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
feedback_gain = '-42dB'
feedback_fine_gain = 1.0
feedback_phase = 124

# -- Tune sweep --
# sweep: harmonic-sweep_range -> harmonic+sweep_range

harmonic = 80
sweep_range = 0.05
tune_reverse = False            # Set to true to sweep backwards

sweep_holdoff = 0
sweep_dwell_time = 100
sweep_gain = '-48dB'

blanking_interval = 10000

detector_input = 'FIR'
det_gain = '0dB'

single_bunch = False            # Set to true for single bunch mode
bunch = 450

# -- Cleaning parameters --
#
cleaning_gain = '0dB'
cleaning_fine_gain = 1.0
cleaning_freq_min = 43.12
cleaning_freq_max = 43.22
cleaning_sweeptime = 20.0
