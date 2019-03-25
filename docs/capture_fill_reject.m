% Script for capturing ADC no fill response
%
% This script exits with the following results:
%
%   scales      Frequency scale for each captured sweep
%   sweeps      IQ data for each frequency sweep
%   labels      Labels for each sweep

mbf = 'TS-DI-TMBF-02';
base_freq = 10;
samples = 1024;

put = @(pv, value) lcaPut([mbf ':X' pv], value);

% Configure loopback
put(':DAC:DELAY_S', 832);
put(':DAC:ENABLE_S', 'Off');
put(':ADC:LOOPBACK_S', 'Loopback');

% Configure the detector
put(':DET:0:ENABLE_S', 'Enabled');
put(':DET:1:ENABLE_S', 'Disabled');
put(':DET:2:ENABLE_S', 'Disabled');
put(':DET:3:ENABLE_S', 'Disabled');
put(':DET:0:SCALING_S', '-48dB');
put(':DET:0:BUNCHES_S', ones(1, 936));
put(':DET:SELECT_S', 'ADC no fill');

% Configure the banks
put(':BUN:0:OUTWF_S', zeros(1, 936));
put(':BUN:1:OUTWF_S', 4 + zeros(1, 936));
put(':BUN:1:GAINWF_S', ones(1, 936));
put(':SEQ:0:BANK_S', 'Bank 0');

% Configure the sequencer.  We'll leave the range and dwell for later on.
put(':SEQ:RESET_S', 0);
put(':SEQ:PC_S', 1);
put(':SEQ:SUPER:COUNT_S', 1);
put(':SEQ:1:COUNT_S', samples);
put(':SEQ:1:HOLDOFF_S', 2);
put(':SEQ:1:GAIN_S', '0dB');
put(':SEQ:1:ENABLE_S', 'On');
put(':SEQ:1:TUNE_PLL_S', 'Ignore');
put(':SEQ:1:BLANK_S', 'Off');
put(':SEQ:1:ENWIN_S', 'Disabled');
put(':SEQ:1:CAPTURE_S', 'Capture');
put(':SEQ:1:BANK_S', 'Bank 1');

% Configure triggers
put(':TRG:SEQ:MODE_S', 'One Shot');
put(':TRG:SEQ:DISARM_S', 0);
sources = {'SOFT'; 'EXT'; 'PM'; 'ADC0'; 'ADC1'; 'SEQ0'; 'SEQ1'};
for n = 1:length(sources)
    put([':TRG:SEQ:' sources{n} ':EN_S'], 'Ignore');
    put([':TRG:SEQ:' sources{n} ':BL_S'], 'All');
end
lcaPut([mbf ':TRG:SOFT_S.SCAN'], '.1 second');
put(':TRG:SEQ:SOFT:EN_S', 'Enable');

fire = @() put(':TRG:SEQ:ARM_S', 0);


% Compute the fill reject option names
labels = {};
for n = 0:12
    labels{n+1} = sprintf('%d turns', 2^n);
end

% Now let's work through and capture everything
scales = zeros(samples, 13);
sweeps = zeros(samples, 13);

for n = 1:13
    disp(sprintf('Capturing %s', labels{n}));

    % The frequency range is a bit of a fudge.  We want the frequency ranges to
    % all be the same length (to help with plotting later on), but the relevant
    % range for each filter differs.  This calculation seems to produce sensible
    % looking graphs.
    start_freq = 0.5 / samples * 2^-(n-4);
    end_freq = min(0.5, (samples + 1) * start_freq);

    put(':ADC:REJECT_COUNT_S', labels{n});
    dwell = 4 * 2^(n-1);

    put(':SEQ:1:DWELL_S', dwell);
    put(':SEQ:1:STATE_HOLDOFF_S', dwell);
    put(':SEQ:1:START_FREQ_S', base_freq + start_freq);
    put(':SEQ:1:END_FREQ_S', base_freq + end_freq);

    fire();
    [iq, s] = mbf_read_det(mbf, 'axis', 0, 'lock', 60);
    scales(:, n) = s - base_freq;
    sweeps(:, n) = iq / dwell;
end
