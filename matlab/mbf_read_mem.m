% d = mbf_read_mem(mbf, turns ...
%       [, 'offset', offset] [, 'channel', channel], [, 'lock', timeout] ...
%       ['bunch', bunch | [, 'tune', tune] [, 'decimate', decimate]])
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
%
% If 'tune' is specified then the captured data will be frequency shifted to the
% specified tune and will be returned as complex numbers.  If 'decimate' is
% specified then data will be averaged bunch by bunch to reduce the amount of
% transmitted data.  Note that the number of turns will still be read.
%
% Alternatively, a single bunch can be requested by setting 'bunch'.  This
% cannot be combined with 'tune' or 'decimate'.

function a = mbf_read_mem(mbf, turns, varargin)
    % Argument parsing
    p = inputParser;
    addParamValue(p, 'offset', 0);
    addParamValue(p, 'channel', -1);
    addParamValue(p, 'lock', -1);
    addParamValue(p, 'tune', 0);
    addParamValue(p, 'decimate', 1);
    addParamValue(p, 'bunch', -1);
    parse(p, varargin{:});

    offset = p.Results.offset;
    channel = p.Results.channel;
    locking = p.Results.lock;
    tune = p.Results.tune;
    decimate = p.Results.decimate;
    bunch = p.Results.bunch;

    % Pick up server address and machine parameters
    server = deblank(char(lcaGet([mbf ':HOSTNAME'])));
    port = lcaGet([mbf ':SOCKET']);

    a = mex_mbf_memory_( ...
        server, port, turns, offset, channel, locking, ...
        tune, decimate, bunch);
end
