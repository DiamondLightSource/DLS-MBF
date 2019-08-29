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
    helpers.get_fits = @(varargin) get_fits(helpers, varargin{:});
    helpers.export_fits = ...
        @(filename, varargin) export_fits(helpers, filename, varargin{:});
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

function [fits, residuals, offsets] = get_fits(h, range)
    if ~exist('range', 'var')
        range = 1:length(h.fits);
    end
    n_fits = length(range);

    fits = {};
    residuals = nan(n_fits, 1);
    offsets = nan(n_fits, 1);

    for n = 1:n_fits
        result = h.fits{range(n)};
        fit = result.fit{1};
        [~, ix] = sort(real(fit(:, 2)));
        fits{n} = fit(ix, :);
        residuals(n) = result.fit{2};
        offsets(n) = result.scale_offset;
    end

    % A nasty matlab style hack: if only one fit being returned, unwrap it from
    % its cell array.
    if n_fits == 1
        fits = fits{1};
    end
end

function export_fits(h, filename, varargin)
    [fits, residuals, offsets] = h.get_fits(varargin{:});

    f = fopen(filename, 'w');
    fprintf(f, '# tune-offset residual (scaling, pole)*n\n');

    for n = 1:size(fits, 1)
        fprintf(f, '%+10.3e ', offsets(n));
        print_complex(f, residuals(n));
        for k = 1:size(fits, 2)
            for j = 1:2
                print_complex(f, fits(n, k, j));
            end
        end
        fprintf(f, '\n');
    end

    fclose(f);
end

function print_complex(f, z)
    fprintf(f, '%+10.3e + I%+10.3e ', real(z), imag(z));
end
