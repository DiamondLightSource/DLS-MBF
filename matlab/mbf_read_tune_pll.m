% result = mbf_read_tune_pll(mbf, [, axis], count, ...
%     [, 'debug'] [, 'no_bar' | 'no_progress'] [, 'fresh'])
%
% This is an overloaded function for reading offset or debug data from the Tune
% PLL source.  The axis argument is mandatory when the mbf is in transverse
% mode, and must not be specified when in longitudinal mode.  Also in transverse
% mode the axis argument can be used to capture data from both axes.  In effect
% this function can be used in the following modes:
%
%   offsets = read(tmbf, axis, count)       Read offsets for one TMBF axis
%   offsets = read(lmbf, count)             Read offsets for LMBF
%   offsets = read(tmbf, 'XY', count)       Read combined TMBF offsets
%   debug = read(mbf [, axis], count, 'debug')    Read debug data
%
% Arguments are described in detail below:
%
%   mbf
%       This must name the MBF server from which data will be captured, not
%       including the axis part of the name.
%
%   axis
%       If mbf is running in longitudinal mode this argument must be omitted,
%       otherwise this should be the name of the axis to be captured (typically
%       'X' or 'Y'), or can name both axes (ie, 'XY') to select simultaneous
%       capture of data from both axes.
%
%   count
%       This identifies how many samples of data are to be captured.  In
%       practice, data will be return in multiples of the buffer length.
%
%   'debug'
%       By default Tune PLL offset data is captured.  If this optional argument
%       is specified then debug IQ data is captured and returned instead.
%
%   'no_bar'
%   'no_progress'
%       By default a graphical progress bar is shown.  If 'no_bar' is specified
%       (or if matlab is in non-graphical mode) then progress is shown on the
%       command line, or 'no_progress' can be specified to suppress progress
%       altogether.
%
%   'fresh'
%       This optional option forces the first buffer of data to be discarded to
%       ensure that captured data is more up to date.

function result = mbf_read_tune_pll(varargin)
    % Parse the arguments
    [mbf_axes, count, debug, show_bar, fresh] = parse_args(varargin{:});

    % If dual axis capture requested ensure that this is reasonable
    n_axes = size(mbf_axes, 1);
    if n_axes > 1
        dwell = lcaGet(make_axis_pvs(mbf_axes, ':PLL:DET:DWELL_S'));
        assert(diff(dwell) == 0, ...
            'Cannot capture from axes with different dwell times');
    end

    % Select the data to capture and the state to monitor depending on whether
    % we're capturing offset or debug data
    if debug
        status_pvs = make_axis_pvs(mbf_axes, ':PLL:DEBUG:ENABLE_S');
        data_pvs = make_axis_pvs(mbf_axes, ...
            {':PLL:DEBUG:WFI'; ':PLL:DEBUG:WFQ'});
        message = 'Debug';
    else
        status_pvs = make_axis_pvs(mbf_axes, ':PLL:CTRL:STATUS');
        data_pvs = make_axis_pvs(mbf_axes, ':PLL:NCO:OFFSETWF');
        message = 'Tune PLL';
    end

    % Check initial state
    assert(all(lcaGet(status_pvs, 0, 'int')), '%s not running', message);

    % Set up CA monitor on the waveform, make sure we clean up on exit
    lcaSetMonitor(data_pvs);
    pv_cleanup = onCleanup(@() lcaClear(data_pvs));

    % Ensure we get fresh data by discarding current data reading
    if fresh
        lcaGet(data_pvs);
    end;

    % Finally capture the requested data, bailing out if PLL not running.
    result = capture_data(show_bar, count, data_pvs, status_pvs, message);
    if debug
        % Gather debug result into IQ values
        result = result(:, 1:2:end) + 1i * result(:, 2:2:end);
    end
end


% Helper function for argument parsing
function [mbf_axis, count, debug, show_bar, fresh] = parse_args(mbf, varargin)
    axis_names = lcaGet({[mbf ':INFO:AXIS0']; [mbf ':INFO:AXIS1']});
    both_axes = strjoin(axis_names, '');

    % lmbf mode affects the available arguments
    if lcaGet([mbf ':INFO:MODE'], 0, 'int')
        % In LMBF mode we know the axis name to use, there's no choice!
        axis = both_axes;
        mbf_axis = {[mbf ':' axis]};
    else
        % In TMBF mode the first argument must be the axis name
        [axis, varargin] = read_one_arg('axis', varargin);
        if strcmp(axis, both_axes)
            % This is a bit of a hack: if we specify 'XY' then we are requesting
            % capture of both axes.
            mbf_axis = {[mbf ':' axis_names{1}]; [mbf ':' axis_names{2}]};
        else
            mbf_axis = {[mbf ':' axis]};
        end
    end
    [count, varargin] = read_one_arg('count', varargin);

    % Now parse the remaining options
    debug = false;
    fresh = false;
    show_bar = 1;
    for n = 1:length(varargin)
        arg = varargin{n};
        switch arg
            case 'debug'
                debug = true;
            case 'fresh'
                fresh = true;
            case 'no_bar'
                assert(show_bar == 1, 'Bar option already set');
                show_bar = 0;
            case 'no_progress'
                assert(show_bar == 1, 'Bar option already set');
                show_bar = -1;
            otherwise
                assert(false, 'Invalid argument "%s"', arg)
        end
    end
end


% Helper function for reading a single argument
function [result, residue] = read_one_arg(name, args)
    assert(~isempty(args), 'Argument %s missing', name);
    result = args{1};
    residue = args(2:end);
end


% Helper function for creating axis PVs from a list, or possibly two lists.
function result = make_axis_pvs(axis_list, pvs)
    if ischar(pvs)
        pvs = {pvs};
    end
    result = {};
    m = 1;
    for n = 1:length(axis_list)
        for k = 1:length(pvs)
            result{m, 1} = [axis_list{n} pvs{k}];
            m = m + 1;
        end
    end
end


% Helper function for data capture
function result = capture_data(show_bar, count, data_pvs, status_pvs, message)
    bar = progress_bar('Fetching data', show_bar);
    result = [];
    while size(result, 1) < count
        while ~all(lcaNewMonitorValue(data_pvs))
            if ~all(lcaGet(status_pvs, 0, 'int'))
                warning('%s not running', message)
                return
            end
            pause(0.01);
        end
        result = [result; lcaGet(data_pvs)'];
        if ~bar.advance(size(result, 1) / count)
            break
        end
    end
end
