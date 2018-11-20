# Top level tune fitting

import numpy

import support
import dd_peaks
import prefit
import refine


MAXIMUM_ANGLE = 100.0


def fit_multiple_peaks(config, scale, iq):
    models = []
    dd_traces = []
    refine_traces = []
    model = (numpy.zeros((0, 2)), 0)
    models.append(model)
    last_error = 'Nothing fitted'
    for n in range(config.MAX_PEAKS):
        model, dd_trace, refine_trace = \
            refine.add_one_pole(config, scale, iq, model)

        if model is None:
            last_error = 'Adding new pole failed'
        else:
            last_error = assess_model(config, scale, model)
        if last_error:
            break

        models.append(model)
        dd_traces.append(dd_trace)
        refine_traces.append(refine_trace)

    return (models, dd_traces, refine_traces, last_error)


# Checks whether the model is convincing.  There are four checks that can fail:
#
#   1.  A rather arbitrary minimum peak width is specified, narrower peaks are
#       simply rejected out of hand.  Conveniently, this also catches the
#       unstable case of negative peak widths.
#
#   2.  We prevent peaks from approaching too close to one another.  This one is
#       a little delicate, as actually it's quite possible for peaks to approach
#       surprisingly closely.
#
#   3.  One disagreeable fitting phenomenon is when two peaks approach each
#       other and work to cancel one another.  Fortunately it turns out that the
#       peaks are around 180 degrees out of phase when this happens, and we
#       normally expect the phase differences between our peaks to be relatively
#       small.
#
#   4.  Finally, relatively small peaks represent fitting errors and can be
#       discarded.
def assess_model(config, scale, model):
    peaks, _ = model
    aa = peaks[:, 0]
    bb = peaks[:, 1]
    centres = bb.real
    widths = -bb.imag

    # First ensure that no peaks are below the minimum width
    if (widths < config.MINIMUM_WIDTH).any():
        return 'Peak too narrow'

    # Check peak hasn't fallen out of range
    lr = scale[[0, -1]]
    l, r = min(lr), max(lr)
    if ((centres < l) | (r < centres)).any():
        return 'Peak out of range'

    # Ensure that peak separations are sensible
    ix1, ix2 = numpy.triu_indices(len(peaks), 1)
    if (numpy.abs(centres[ix1] - centres[ix2]) < config.MINIMUM_SPACING).any():
        return 'Peaks too close'

    # Check for peak phases: if one peak is out of place reject
    m = numpy.mean(aa * widths)
    angles = 180 / numpy.pi * numpy.angle(aa / m)
    if (numpy.abs(angles) > MAXIMUM_ANGLE).any():
        return 'Possible peak merging'

    # Check for small peaks
    heights = numpy.abs(aa) / widths
    min_height = config.MINIMUM_HEIGHT * numpy.max(heights)
    if (heights < min_height).any():
        return 'Peak too small'

    return ''


def peaks_power(peaks):
    aa, bb = peaks.T
    return support.abs2(aa) / -bb.imag

def sort_by_frequency(peaks):
    return peaks[numpy.argsort(peaks[:, 1].real)]


def find_three_peaks(peaks):
    count = len(peaks)
    if count == 0:
        return (None, None, None)
    else:
        # Take the peak with the largest power as the tune, return the
        # neighbouring peaks as the sidebands, or return empty peaks if none
        # available.
        peaks = sort_by_frequency(peaks)
        maxix = numpy.argmax(peaks_power(peaks))
        padded = [None] + list(peaks) + [None]
        return padded[maxix:maxix+3]


def compute_peak_info(peak):
    if peak is None:
        a = numpy.nan + 1j * numpy.nan
        b = numpy.nan + 1j * numpy.nan
        valid = False
    else:
        a, b = peak
        valid = True

    width = -b.imag
    power = support.abs2(a) / width
    height = power / width
    return support.Trace(
        valid = valid,
        tune = numpy.mod(b.real, 1),
        phase = 180 / numpy.pi * numpy.angle(-1j * a),
        width = width,
        power = power,
        height = numpy.sqrt(power / width))


def compute_delta_info(centre, side):
    phase = side.phase - centre.phase
    if phase > 180:
        phase -= 360
    elif phase < -180:
        phase += 360
    return support.Trace(
        tune = numpy.abs(side.tune - centre.tune),
        phase = phase,
        power = side.power / centre.power,
        width = side.width / centre.width,
        height = side.height / centre.height)


def compute_tune_result(config, peaks, fit_error):
    if fit_error > config.MAXIMUM_FIT_ERROR or not numpy.isfinite(fit_error):
        peaks = []
    left, centre, right = find_three_peaks(peaks)

    left = compute_peak_info(left)
    centre = compute_peak_info(centre)
    right = compute_peak_info(right)
    delta_left = compute_delta_info(centre, left)
    delta_right = compute_delta_info(centre, right)

    tune = support.Trace(
        tune = centre.tune, phase = centre.phase,
        synctune = 0.5 * (delta_left.tune + delta_right.tune))
    return support.Trace(
        tune = tune,
        left = left, centre = centre, right = right,
        delta_left = delta_left, delta_right = delta_right)


# Clip the data to the requested window
def compute_window(config, scale, iq):
    start = config.WINDOW_START
    length = config.WINDOW_LENGTH
    if length <= 0:
        window = slice(start, None)
    else:
        window = slice(start, start + length)
    return scale[window], iq[window]


def fit_tune(config, scale, iq):
    scale, iq = compute_window(config, scale, iq)

    power = support.abs2(iq)
    input_trace = support.Trace(scale = scale, iq = iq, power = power)

    # For subsequent processing remove the mean value from the scale
    scale_offset = scale.mean()
    scale = scale - scale_offset

    # Incrementally fit the required number of peaks
    models, dd_traces, refine_traces, last_error = \
        fit_multiple_peaks(config, scale, iq)
    model = models[-1]

    model_iq, residue, fit_error = refine.compute_fit_error(scale, iq, model)
    output_trace = support.Trace(
        fit_error = fit_error,
        model = model_iq,
        model_power = support.abs2(model_iq),
        residue = residue)

    # Compute final peak result after first extracting the peaks part of the
    # final fitted model and restoring the scale offset.
    peaks, _ = model
    peaks = peaks + [0, scale_offset]
    tune = compute_tune_result(config, peaks, fit_error)

    if not last_error:
        last_error = 'Fit ok'
    return support.Trace(
        input = input_trace,
        output = output_trace,
        scale_offset = scale_offset,
        dd = dd_traces,
        refine = refine_traces,
        models = models,
        fit_error = fit_error,
        last_error = last_error,
        fit_length = len(iq),
        tune = tune)
