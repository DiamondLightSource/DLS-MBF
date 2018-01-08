# Top level tune fitting

import numpy

import support
import dd_peaks
import prefit
import refine


def fit_tune_model(config, scale, iq):
    # First extract candidate ranges from second derivative of power spectrum
    power = support.abs2(iq)
    input_trace = support.Struct(scale = scale, iq = iq, power = power)

    ranges, dd_trace = dd_peaks.get_peak_ranges(config, power)

    # For subsequent processing remove the mean value from the scale
    scale_offset = scale.mean()
    scale = scale - scale_offset

    # Next perform a preliminary fit to the list of ranges
    peaks, prefit_trace = prefit.prefit_ranges(config, scale, iq, ranges)

    # Now refine the fit with rounds of LM fitting
    model, refine_trace = refine.refine_fits(config, scale, iq, peaks)

    trace = support.Struct(
        input = input_trace,
        dd = dd_trace,
        prefit = prefit_trace,
        refine = refine_trace)
    return (model, trace)


def fit_tune(config, scale, iq):
    model, trace = fit_tune_model(config, scale, iq)
    return trace


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
    output_dd(result.peak16, trace.dd.peaks_16, max_peaks)
    output_dd(result.peak64, trace.dd.peaks_64, max_peaks)
#     output_poles(result.fits1, trace.prefit.fit, max_peaks)
#     output_poles(result.fits2, trace.refine.fit, max_peaks)
