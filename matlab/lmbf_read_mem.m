% d = lmbf_read_mem(lmbf, turns ...
%       [, 'offset', offset] [, 'channel', channel], [, 'lock', timeout])
%
% Reads the specified number of turns from fast memory from given device.  If
% offset is not specified it defaults to 0, otherwise data is read starting from
% offset turns relative to the trigger.
%
% The channel can be specified as 0 or 1 to read only one memory channel, or -1
% (or unspecified) to read both memory channels.
%
% If 'lock' is requested then the memory will only be read while the trigger is
% idle, and the caller will wait timeout seconds for the trigger to become
% ready.  A timeout of zero means no waiting, the call will fail if the trigger
% is not ready.

function a = lmbf_read_mem(lmbf, turns, varargin)
    % Argument parsing
    p = inputParser;
    addParamValue(p, 'offset', 0);
    addParamValue(p, 'channel', -1);
    addParamValue(p, 'lock', -1);
    parse(p, varargin{:});
    offset = p.Results.offset;
    channel = p.Results.channel;
    locking = p.Results.lock;

    % Pick up server address and machine parameters
    server = deblank(char(lcaGet([lmbf ':HOSTNAME'])));
    port = lcaGet([lmbf ':SOCKET']);
    bunches = lcaGet([lmbf ':BUNCHES']);

    a = mex_lmbf_memory_( ...
        server, port, bunches, turns, offset, channel, locking);
end
