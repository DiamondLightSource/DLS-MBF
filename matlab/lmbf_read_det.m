% [d, s, t] = lmbf_read_det(lmbf [, 'channel', channel] [, 'lock', timeout])
%
% Reads out the currently captured detectors for the given channel.  If no
% channel is specified, the default is 0.  The frequency scale and timebase are
% returned if requested.

function [d, s, varargout] = lmbf_read_mem(lmbf, varargin)
    % Default arguments and argument parsing
    p = inputParser;
    addParamValue(p, 'channel', 0);
    addParamValue(p, 'lock', -1);
    parse(p, varargin{:});
    channel = p.Results.channel;
    locking = p.Results.lock;

    % Pick up server address
    server = deblank(char(lcaGet([lmbf ':HOSTNAME'])));
    port = lcaGet([lmbf ':SOCKET']);
    bunches = lcaGet([lmbf ':BUNCHES']);

    % Capture detector data, frequency scale, group delay, and optional timebase
    [d, s, g, varargout{1:nargout-2}] = ...
        mex_lmbf_detector_(server, port, bunches, channel, locking);

    % Phase correction of captured data
    d = repmat(exp(-1i * g * s), 1, size(d, 2)) .* d;
end
