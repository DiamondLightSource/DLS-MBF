% Script to plot fill reject filter sweeps
%
% The values scales, sweeps, labels must be defined as captured by the
% capture_fill_reject script.

% Normalise the sweeps
nsweeps = sweeps ./ mean(sweeps(end, 2:end));

% First plot the magnitudes
semilogx(scales, 20 * log10(abs(nsweeps)));
xlim([1e-5 0.5])
ylim([-25 10])
xlabel('Offset from turn frequency in fractions of turn')
ylabel('Response in dB')
title('Magnitude response of Fill Reject filters')
legend(labels, 'Location', 'SouthEast')

% Label each curve
[m, ix] = max(abs(nsweeps));
for n = 2:13
    text(scales(ix(n), n), 5, sprintf('%d', 2^(n-1)), ...
        'HorizontalAlignment', 'center');
end


% Now plot the angles
figure
angles = 180/pi * angle(nsweeps);
semilogx(scales, angles);
xlim([1e-5 0.5])
ylim([-90 20]);
xlabel('Offset from turn frequency in fractions of turn')
ylabel('Response in degrees')
title('Phase response of Fill Reject filters')
legend(labels, 'Location', 'SouthEast')

% Label each curve
[m, ix] = max(angles);
for n = 2:13
    text(scales(ix(n), n), angles(ix(n), n) + 2, sprintf('%d', 2^(n-1)), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom');
end
