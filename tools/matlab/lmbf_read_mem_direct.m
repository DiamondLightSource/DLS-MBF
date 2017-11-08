% Quick and dirty matlab script to capture and read ADC waveform.
function a = lmbf_read_mem_direct(lmbf, turns)
    device = lcaGet([lmbf ':DEVICE']);
    origin = lcaGet([lmbf ':MEM:ORIGIN']);
    bunches = lcaGet([lmbf ':BUNCHES']);

    samples = 2 * bunches * turns;
    device = sprintf('/dev/amc525_lmbf/%s/amc525_lmbf.ddr0', device{1});

    f = fopen(device);
    fseek(f, origin, 'bof');
    a = double(reshape(fread(f, samples, 'int16=>int16'), 2, [])');
    fclose(f);
end
