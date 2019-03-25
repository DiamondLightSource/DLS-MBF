%   offset = mbf_read_tune_pll(mbf, count [, axis] [, 'progress', progress_bar])
%
% Captures given number of points of Tune PLL data for the specified axis.  For
% LMBF mode no axis should be specified, for TMBF mode the axis argument is
% mandatory.  The 'progress' argument can be set to 0 to suppress the progress
% bar pop-up or to -1 to completely suppress progress reporting.

function offset = mbf_read_tune_pll(mbf, count, varargin)
    % lmbf mode affects the available arguments
    lmbf = lcaGet([mbf ':INFO:MODE'], 0, 'int');
    axis_names = lcaGet({[mbf ':INFO:AXIS0']; [mbf ':INFO:AXIS1']});
    if lmbf
        % In LMBF mode we know the axis name to use, there's no choice!
        axis = strjoin(axis_names, '');
    else
        % In TMBF mode eat the first varargin argument to select the axis
        axis = varargin{1};
        varargin = varargin(2:end);
        if ~ischar(axis)
            axis = axis_names{axis + 1};
        end
    end
    mbf_axis = [mbf ':' axis];

    % Use an argument parser to figure out the progress bar
    p = inputParser;
    addParamValue(p, 'progress', 1);
    parse(p, varargin{:});
    progress = p.Results.progress;

    % Set up CA monitor on the waveform, make sure we clean up on exit
    pv = [mbf_axis ':PLL:NCO:OFFSETWF'];
    lcaSetMonitor(pv);
    pv_cleanup = onCleanup(@() lcaClear(pv));

    if progress >= 0
        bar = progress_bar('Fetching data', progress);
    else
        bar = {};
        bar.advance = @(n) true;
    end

    status_pv = [mbf_axis ':PLL:CTRL:STATUS'];

    % Finally capture the requested data, bailing out if PLL not running.
    offset = [];
    while length(offset) < count
        while ~lcaNewMonitorValue(pv);
            assert(lcaGet(status_pv, 0, 'int') == 1, ...
                'Tune PLL not running on %s', mbf_axis);
            pause(0.1);
        end
        offset = [offset lcaGet(pv)];
        if ~bar.advance(length(offset) / count); break; end
    end
end
