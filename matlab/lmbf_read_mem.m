% d = lmbf_read_mem(lmbf, turns [, offset])
%
% Reads the specified number of turns from fast memory from given device.  If
% offset is not specified it defaults to 0, otherwise data is read starting from
% offset turns relative to the trigger.

function a = lmbf_read_mem(lmbf, turns, offset)
    % Default arguments
    if ~exist('offset', 'var'); offset = 0; end

    % Pick up server address
    server = deblank(char(lcaGet([lmbf ':HOSTNAME'])));
    port = lcaGet([lmbf ':SOCKET']);
    bunches = lcaGet([lmbf ':BUNCHES']);

    a = lmbf_memory_mex(server, port, bunches, turns, offset);
end
