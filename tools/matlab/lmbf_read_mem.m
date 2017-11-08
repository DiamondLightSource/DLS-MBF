% Matlab script to read DRAM0 data from LMBF server

function a = lmbf_read_mem(lmbf, turns, offset)
    % Default arguments
    if ~exist('offset', 'var'); offset = 0; end

    % Pick up server address
    server = deblank(char(lcaGet([lmbf ':HOSTNAME'])));
    port = lcaGet([lmbf ':SOCKET']);

    % Capture data over socket connection to temporary file
    filename = tempname;
    command = sprintf('echo MR%dO%dC | nc %s %d >%s', ...
        turns, offset, server, port, filename);
    system(command);

    % Load temporary file into matlab as array of doubles
    f = fopen(filename);
    a = double(reshape(fread(f, inf, 'int16=>int16'), 2, [])');
    fclose(f);
    delete(filename);
end
