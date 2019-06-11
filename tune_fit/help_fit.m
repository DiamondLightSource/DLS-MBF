% Miscellaneous helpers for tune fit calculation

function helpers = help_fit(fits)
    helpers = {};
    helpers.fits = fits;

    helpers.model = @(n, s) ...
        model(fits{n}.fit{1}, fits{n}.fit{2}, ...
            s - fits{n}.scale_offset);
    helpers.plot_fit = @(n) plot_fit(helpers, n);
    helpers.plot_fits = @(varargin) plot_fits(helpers, varargin{:});
    helpers.raw_model = @(fit, s) model(fit{1}, fit{2}, s);
end

function m = model(fit, offset, s)
    s = s(:)';
    % In matlab 2019 the following can be more concisely written thus:
    %     m = sum(fit(:,1) ./ (s - fit(:,2)), 1) + offset;
    n_s = size(s, 2);
    n_fit = size(fit, 1);
    m = sum( ...
        repmat(fit(:, 1), 1, n_s) ./ ...
        (repmat(s, n_fit, 1) - repmat(fit(:, 2), 1, n_s)), 1) + offset;

    m = m(:);
end

function plot_fit(h, n)
    iq = h.fits{n}.input.iq;
    s = h.fits{n}.input.scale;
    semilogy(s, abs(iq), '.', s, abs(h.model(n, s)))
    xlim(s([1 end]))
    legend('data', 'model')
end

function plot_fits(h, range)
    if ~exist('range', 'var')
        range = 1:length(h.fits);
    end
    count = length(range);
    for n = 1:count
        subplot(count, 1, n)
        h.plot_fit(range(n))
    end
end
