% bar = progress_bar(title, [show_bar])
%
% Creates a progress bar which can be updated periodically to show data capture
% or computation progress.  The progress bar will be removed when the returned
% value is deleted.
%
% Call the following function on the progress bar to check and update it:
%
%   ok = bar.advance(fraction)
%       Update progress bar to show progress as fraction done.  The fraction
%       should be a number in the range 0 to 1.  Returns false if the cancel
%       button has been pressed.

function bar = progress_bar(title, show_bar)
    bar = {};

    % Advances the GUI waitbar
    function ok = advance_waitbar(fraction)
        waitbar(fraction, bar.wb);
        ok = ~getappdata(bar.wb, 'cancelling');
    end

    % Advances the console only waitbar replacement.  Alas, cannot catch Ctrl-C
    % in any useful way here, so isn't cancellable.
    function ok = show_advance(fraction)
        fprintf(2, '%5.2f%%\r', 100 * fraction)
        ok = true;
    end

    % Determine whether to show the progress bar.  If we're headless we don't
    % show it, otherwise hide it if show_bar is set to false.
    headless = length(java.lang.System.getProperty('java.awt.headless')) > 0;
    if exist('show_bar', 'var') && ~show_bar
        headless = true;
    end

    if headless
        bar.cleanup = onCleanup(@() fprintf(2, 'Done   \n'));
        bar.advance = @show_advance;
    else
        bar.wb = waitbar(0, title, ...
            'CreateCancelBtn', 'setappdata(gcbf, ''cancelling'', 1)');
        bar.cleanup = onCleanup(@() delete(bar.wb));
        setappdata(bar.wb, 'cancelling', 0);

        bar.advance = @advance_waitbar;
    end
end
