% Quick and dirty matlab script to capture and read ADC waveform.
function a = lmbf_adc(samples)

reg = [fileparts(mfilename('fullpath')) '/../reg'];
device = '/dev/amc525_lmbf.0.ddr0';

% 2 samples per capture, plus a bit of overrun
system(sprintf('%s 1 3 %d', reg, ceil(samples/2) + 16));
% Trigger capture
system(sprintf('%s 1 4 3', reg));

f = fopen(device);
a = double(reshape(fread(f, 2*samples, 'int16=>int16'), 2, [])');
fclose(f);
