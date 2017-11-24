% d = lmbf_read_mem(lmbf, turns [, 'offset', offset] [, 'channel', channel])
%
% Reads the specified number of turns from fast memory from given device.  If
% offset is not specified it defaults to 0, otherwise data is read starting from
% offset turns relative to the trigger.
%
% The channel can be specified as 0 or 1 to read only one memory channel, or -1
% (or unspecified) to read both memory channels.

function a = lmbf_read_mem(lmbf, turns, varargin)
    % Argument parsing
    p = inputParser;
    addParamValue(p, 'offset', 0);
    addParamValue(p, 'channel', -1);
    parse(p, varargin{:});
    offset = p.Results.offset;
    channel = p.Results.channel;

    % Pick up server address and machine parameters
    server = deblank(char(lcaGet([lmbf ':HOSTNAME'])));
    port = lcaGet([lmbf ':SOCKET']);
    bunches = lcaGet([lmbf ':BUNCHES']);

    a = mex_lmbf_memory_(server, port, bunches, turns, offset, channel);
end
