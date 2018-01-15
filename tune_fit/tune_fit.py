# Top level tune fitting

import numpy

import support
import dd_peaks
import prefit
import refine


MINIMUM_WIDTH = 1e-5

MINIMUM_SPACING = 1

MAXIMUM_ANGLE = 100

MINIMUM_HEIGHT = 0.1


def fit_multiple_peaks(config, scale, iq):
    max_peaks = config.max_peaks
    models = []
    dd_traces = []
    refine_traces = []
    model = (numpy.zeros((0, 2)), 0)
    for n in range(max_peaks):
        model, dd_trace, refine_trace = \
            refine.add_one_pole(config, scale, iq, model)

        if model is None or not assess_model(config, model):
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
def assess_model(config, model):
    peaks, _ = model
    aa = peaks[:, 0]
    bb = peaks[:, 1]
    widths = -bb.imag

    # First ensure that no peaks are below the minimum width
    if (widths < MINIMUM_WIDTH).any():
        return False

    # Ensure that peak separations are sensible
    ix1, ix2 = numpy.triu_indices(len(peaks), 1)
    max_width = MINIMUM_SPACING * numpy.maximum(widths[ix1], widths[ix2])
    if (numpy.abs(bb[ix1] - bb[ix2]) < max_width).any():
        return False

    # Check for peak phases: if one peak is out of place reject
    m = numpy.mean(aa * widths)
    angles = 180 / numpy.pi * numpy.angle(aa / m)
    if (numpy.abs(angles) > MAXIMUM_ANGLE).any():
        return False

    # Check for small peaks
    heights = numpy.abs(aa) / widths
    min_height = MINIMUM_HEIGHT * numpy.max(heights)
    if (heights < min_height).any():
        return False

    return True


def sort_peaks(model, offset):
    peaks, _ = model
    sortix = numpy.argsort(peaks[:, 1].real)
    peaks = peaks[sortix] + [0, offset]
    return peaks


def find_three_peaks(peaks):
    count = len(peaks)
    if count == 0:
        return (None, None, None)
    elif count == 1:
        return (None, peaks[0], None)
    elif count == 2:
        maxix = numpy.argmax(support.abs2(aa) / -bb.imag)
        if maxix == 0:
            return (None, peaks[0], peaks[1])
        else:
            return (peaks[0], peaks[1], None)
    else:
        return tuple(peaks)


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
        height = area / width)


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
        height = side.width / centre.width)


def compute_tune_result(model, scale_offset):
    peaks = sort_peaks(model, scale_offset)
    left, centre, right = find_three_peaks(peaks)

    left = compute_peak_info(left)
    centre = compute_peak_info(centre)
    right = compute_peak_info(right)
    delta_left = compute_delta_info(centre, left)
    delta_right = compute_delta_info(centre, right)

    tune = support.Trace(tune = centre.tune, phase = centre.phase)
    return support.Trace(
        tune = tune,
        left = left, centre = centre, right = right,
        delta_left = delta_left, delta_right = delta_right)


def fit_tune_model(config, scale, iq):
    power = support.abs2(iq)
    input_trace = support.Trace(scale = scale, iq = iq, power = power)

    # For subsequent processing remove the mean value from the scale
    scale_offset = scale.mean()
    scale = scale - scale_offset

    # Incrementally fit the required number of peaks
    models, dd_traces, refine_traces = fit_multiple_peaks(config, scale, iq)

    # Compute final peak result
    tune = compute_tune_result(models[-1], scale_offset)
    tune._print()

    return support.Trace(
        input = input_trace,
        scale_offset = scale_offset,
        dd = dd_traces,
        refine = refine_traces,
        tune = tune)



# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Output results

def output_input(result, trace):
    result.output(
        scale = trace.scale, i = trace.iq.real, q = trace.iq.imag,
        power = trace.power)


# Converts [(ix, l, r)] into ([ix], [l], [r], [power]) for presentation
def output_dd(result, trace, max_peaks):
    power = trace.smoothed
    dd = trace.dd
    peaks = trace.peaks

    def pad(l):
        a = numpy.zeros(max_peaks)
        a[:len(l)] = l
        return a

    ix, l, r = zip(*peaks)
    p = power[list(ix)]

    result.output(
        power = power,
        pdd = dd,
        ix = pad(ix),
        l = pad(l),
        r = pad(r),
        v = pad(p))


def output_poles(result, fits, max_peaks):
    aa = numpy.zeros(max_peaks, dtype = numpy.complex128)
    bb = numpy.zeros(max_peaks, dtype = numpy.complex128)
    N = fits.shape[0]
    aa[:N] = fits[:, 0]
    bb[:N] = fits[:, 1]
    result.output(ar = aa.real, ai = aa.imag, br = bb.real, bi = bb.imag)


# Updates the result array from the given trace
def update_pvs(config, trace, result):
    max_peaks = config.max_peaks
    output_input(result, trace.input)
#     output_dd(result.peak16, trace.dd.peaks_16, max_peaks)
#     output_dd(result.peak64, trace.dd.peaks_64, max_peaks)
#     output_poles(result.fits1, trace.prefit.fit, max_peaks)
#     output_poles(result.fits2, trace.refine.fit, max_peaks)
