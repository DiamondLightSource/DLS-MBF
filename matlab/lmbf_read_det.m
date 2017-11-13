% d = lmbf_read_det(lmbf [, channel])
%
% Reads out the currently captured detectors for the given channel.  If no
% channel is specified, the default is 0.

function a = lmbf_read_mem(lmbf, channel)
    % Default arguments
    if ~exist('channel', 'var'); channel = 0; end

    % Pick up server address
    server = deblank(char(lcaGet([lmbf ':HOSTNAME'])));
    port = lcaGet([lmbf ':SOCKET']);

    a = mex_lmbf_detector_(server, port, channel);
end
