% Quick and dirty matlab script to capture and read ADC waveform.
function a = lmbf_adc(blocks)

reg = [fileparts(mfilename('fullpath')) '/../reg'];
file_in = '/dev/shm/adc';
device = '/dev/amc525_lmbf.0.ddr0';

system(sprintf('%s 1 2 %d; dd if=%s count=%d bs=%d status=none of=%s', ...
    reg, 32768 * blocks, device, blocks, 131072, file_in));

f = fopen(file_in);
a = double(reshape(fread(f, Inf, 'int16=>int16'), 2, [])');
fclose(f);
delete(file_in);
