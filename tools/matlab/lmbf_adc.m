% Quick and dirty matlab script to capture and read ADC waveform.
function a = lmbf_adc(lmbf, samples)

% Once we have the IOC the path to the DRAM device will be available as
%
%   dev = deblank(char(lcaGet([device ':DRAM_NAME'])));

device = deblank(char(lcaGet([lmbf ':MEM:DEVICE'])));
origin = lcaGet([lmbf ':MEM:ORIGIN']);

f = fopen(device);
fseek(f, origin, 'bof');


% capture = [fileparts(mfilename('fullpath')) '/../capture_dram0'];
% [rc, device] = system(sprintf('%s -d %d', capture, samples));

% f = fopen(device);

a = double(reshape(fread(f, 2*samples, 'int16=>int16'), 2, [])');
fclose(f);
