% [d, s, t] = mbf_read_det(mbf [, 'axis', axis] [, 'lock', timeout])
%
% Reads out the currently captured detectors for the given axis.  If no
% axis is specified, the default is 0.  The frequency scale and timebase are
% returned if requested.

function [d, s, varargout] = mbf_read_mem(mbf, varargin)
    % Default arguments and argument parsing
    p = inputParser;
    addParamValue(p, 'axis', 0);
    addParamValue(p, 'lock', -1);
    parse(p, varargin{:});
    axis = p.Results.axis;
    locking = p.Results.lock;

    % Pick up server address
    server = deblank(char(lcaGet([mbf ':HOSTNAME'])));
    port = lcaGet([mbf ':SOCKET']);

    % Capture detector data, frequency scale, group delay, and optional timebase
    [d, s, g, varargout{1:nargout-2}] = ...
        mex_mbf_detector_(server, port, axis, locking);

    % Phase correction of captured data
    d = repmat(exp(-1i * g * s), 1, size(d, 2)) .* d;
end
