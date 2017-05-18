% Quick and dirty matlab script to capture and read ADC waveform.
function a = lmbf_adc(samples)

capture = [fileparts(mfilename('fullpath')) '/../capture_dram0'];
% device = '/dev/amc525_lmbf.0.ddr0';

[rc, device] = system(sprintf('%s -d %d', capture, samples));

f = fopen(device);
a = double(reshape(fread(f, 2*samples, 'int16=>int16'), 2, [])');
fclose(f);
