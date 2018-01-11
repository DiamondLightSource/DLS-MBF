# Top level tune fitting

import numpy

import support
import dd_peaks
import prefit
import refine


def fit_tune_model(config, scale, iq):
    max_peaks = config.max_peaks
    print 'tune_fit_model'

    power = support.abs2(iq)
    input_trace = support.Struct(scale = scale, iq = iq, power = power)

    # For subsequent processing remove the mean value from the scale
    scale_offset = scale.mean()
    scale = scale - scale_offset

    # Fit first peak to entire sweep.  This should be our tune centre.
#     one_peak = prefit.fit_one_pole(scale, iq, power).reshape(1, 2)
#     model, refine_trace = refine.refine_fits(config, scale, iq, one_peak)

    # Incrementally fit the remaining peaks
#     models = [model]
#     traces = [refine_trace]
    models = []
    traces = []
    model = (numpy.zeros((0, 2)), 0)
    for n in range(max_peaks):
        model, refine_trace = refine.add_one_pole(config, scale, iq, model)
        models.append(model)
        traces.append(refine_trace)

    trace = support.Struct(input = input_trace, refine = traces)
    return (model, scale_offset, trace)



def fit_tune(config, scale, iq):
    model, offset, trace = fit_tune_model(config, scale, iq)
    return trace


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
