# Top level tune fitting

import numpy

import support
import dd_peaks
import prefit
import refine


MAXIMUM_FIT_ERROR = 0.2


def fit_multiple_peaks(config, scale, iq):
    models = []
    dd_traces = []
    refine_traces = []
    model = (numpy.zeros((0, 2)), 0)
    models.append(model)
    for n in range(config.MAX_PEAKS):
        model, dd_trace, refine_trace = \
            refine.add_one_pole(config, scale, iq, model)

        if model is None or not assess_model(config, scale, model):
            break

        models.append(model)
        dd_traces.append(dd_trace)
        refine_traces.append(refine_trace)

    return (models, dd_traces, refine_traces)


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
        return False

    # Check peak hasn't fallen out of range
    lr = scale[[0, -1]]
    l, r = min(lr), max(lr)
    if ((centres < l) | (r < centres)).any():
        return False

    # Ensure that peak separations are sensible
    ix1, ix2 = numpy.triu_indices(len(peaks), 1)
    max_width = config.MINIMUM_SPACING * numpy.maximum(widths[ix1], widths[ix2])
    if (numpy.abs(bb[ix1] - bb[ix2]) < max_width).any():
        return False

    # Check for peak phases: if one peak is out of place reject
    m = numpy.mean(aa * widths)
    angles = 180 / numpy.pi * numpy.angle(aa / m)
    if (numpy.abs(angles) > config.MAXIMUM_ANGLE).any():
        return False

    # Check for small peaks
    heights = numpy.abs(aa) / widths
    min_height = config.MINIMUM_HEIGHT * numpy.max(heights)
    if (heights < min_height).any():
        return False

    return True


def sort_by_frequency(peaks):
    return peaks[numpy.argsort(peaks[:, 1].real)]

def sort_by_area(peaks):
    aa, bb = peaks.T
    return peaks[numpy.argsort(support.abs2(aa) / -bb.imag)]


def find_three_peaks(peaks):
    count = len(peaks)
    if count == 0:
        return (None, None, None)
    elif count == 1:
        return (None, peaks[0], None)
    elif count == 2:
        peaks = sort_by_frequency(peaks)
        aa, bb = peaks.T
        maxix = numpy.argmax(support.abs2(aa) / -bb.imag)
        if maxix == 0:
            return (None, peaks[0], peaks[1])
        else:
            return (peaks[0], peaks[1], None)
    else:
        # If three or more peaks, return the three largest
        return tuple(sort_by_frequency(sort_by_area(peaks[:3])))


def compute_peak_info(peak):
    if peak is None:
        a = numpy.nan + 1j * numpy.nan
        b = numpy.nan + 1j * numpy.nan
        valid = False
    else:
        a, b = peak
        valid = True

    width = -b.imag
    area = support.abs2(a) / width
    height = area / width
    return support.Trace(
        valid = valid,
        tune = numpy.mod(b.real, 1),
        phase = 180 / numpy.pi * numpy.angle(-1j * a),
        width = width,
        area = area,
        height = numpy.sqrt(area / width))


def compute_delta_info(centre, side):
    phase = side.phase - centre.phase
    if phase > 180:
        phase -= 360
    elif phase < -180:
        phase += 360
    return support.Trace(
        tune = numpy.abs(side.tune - centre.tune),
        phase = phase,
        area = side.area / centre.area,
        width = side.width / centre.width,
        height = side.height / centre.height)


def compute_tune_result(peaks, fit_error):
    if fit_error > MAXIMUM_FIT_ERROR or not numpy.isfinite(fit_error):
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


def fit_tune(config, scale, iq):
    power = support.abs2(iq)
    input_trace = support.Trace(scale = scale, iq = iq, power = power)

    # For subsequent processing remove the mean value from the scale
    scale_offset = scale.mean()
    scale = scale - scale_offset

    # Incrementally fit the required number of peaks
    models, dd_traces, refine_traces = fit_multiple_peaks(config, scale, iq)
    model = models[-1]

    fit_error = refine.compute_fit_error(scale, iq, model)

    # Compute final peak result after first extracting the peaks part of the
    # final fitted model and restoring the scale offset.
    peaks, _ = model
    peaks = peaks + [0, scale_offset]
    tune = compute_tune_result(peaks, fit_error)

    return support.Trace(
        input = input_trace,
        scale_offset = scale_offset,
        dd = dd_traces,
        refine = refine_traces,
        models = models,
        fit_error = fit_error,
        tune = tune)
