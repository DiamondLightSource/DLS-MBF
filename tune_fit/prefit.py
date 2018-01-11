# Peak prefitting
# Fitting one-pole model to IQ.

import numpy

import support



# Fitting one pole filter to IQ data.  Given waveforms scale[] and wf[], which
# we write here as s[] and iq[], this function computes complex parameters a and
# b to minimise the fitting error for the model
#
#               a
#      z(s) = -----    with nominal error term  en = z - iq
#             s - b    ie, en[i] = z(s[i]) - iq[i] .
#
# As a matter of practicality, minimising this error term requires an expensive
# least squares minimisation, so instead we fudge this by multiplying through by
# (s - b) and a weighting factor w to get the fitted error term
#
#      e = w . (s - b) . en = w . (a + b . iq - iq . s) .
#
# We can minimise E = ||e||^2 = sum_i |e[i]|^2 by solving the overdetermined
# matrix equation
#
#      W M x = W y     where
#          M[i,.] = (1, iq[i]), x = [a; b], y[i] = s[i] . iq[i], W = diag(w).
#
# It turns out that for complex M, x, y, we can solve this by solving the fully
# determined equation
#
#      M^H W M x = M^H W y
#
# This is easily multiplied out to produce the equations:
#
#      [ S(w)      S(w iq)     ] [a] = [ S(w s iq)     ]
#      [ S(w iq)*  S(w |iq|^2) ] [b]   [ S(w s |iq|^2) ]
#
# and this is of course easy to solve for (a,b) by inverting the 2x2 matrix.
#
# Note however that the solution here minimises w.(s-b).en, and without a
# compensating weight this solution gives too much emphasis to points further
# away from the centre frequency b.  This can be fixed by performing the fit
# twice: once with w = 1 and a second time with w = 1 / |s - b|^2; assuming the
# first fit is acceptable, this second fit will refine the fit with more
# emphasis on the points nearer the centre frequency.
#
# The inverse of M^H W M is
#
#      [a] = 1/D [ S(w |iq|^2)  -S(w iq) ] [ S(w s iq)     ]
#      [b]       [ -S(w iq*)    S(w)     ] [ S(w s |iq|^2) ]
# where
#      D = S(2) S(2 |iq|^2) - |S(w iq)|^2

def fit_one_pole(scale, iq, weights = None):
    if weights is None:
        weights = numpy.ones(iq.shape)

    # Compute the components of M^H W M and M^H W y.
    iq2 = support.abs2(iq)
    S_w       = weights.sum()                   # S w
    S_w_iq    = (weights * iq).sum()            # S w iq
    S_w_iq2   = (weights * iq2).sum()           # S w |iq|^2
    S_w_s_iq  = (weights * iq * scale).sum()    # S w s iq
    S_w_s_iq2 = (weights * iq2 * scale).sum()   # S w s |iq|^2

    # Do the inversion by hand
    det = S_w * S_w_iq2 - support.abs2(S_w_iq)
    # Check for a sensible fit, otherwise fail.
    if len(iq) >= 2  and  abs(det) > S_w:
        a = (S_w_iq2 * S_w_s_iq - S_w_iq * S_w_s_iq2) / det
        b = (S_w * S_w_s_iq2 - numpy.conj(S_w_iq) * S_w_s_iq) / det
        return numpy.array([a, b])
    else:
        raise Exception('Singular fit')


# Computes model for a single fit
def eval_one_peak(fit, s):
    a, b = fit
    return a / (s - b)


# Evaluates model from a list of fits
def eval_model(scale, fits, offset = 0):
    result = numpy.zeros(scale.shape, dtype = numpy.complex)
    for fit in fits:
        result += eval_one_peak(fit, scale)
    return result + offset


# Take as much of the existing model into account by subtracting it from the
# data we're about to fit.
def adjust_iq_with_model(fits, fit_ix, scale, iq):
    for ix, fit in enumerate(fits):
        if ix != fit_ix and fit:
            iq -= eval_one_peak(fit, scale)
    return iq


# The weight function here is 1/|z-b|^2 and helps to ensure a cleaner curve
# fit.  The first 1/|z-b| factor helps cancel out a weighting error in the
# model, and the second factor puts more emphasis on fitting the peak.
#   Note that the absolute scaling of the returned result is immaterial.
def compute_weights(scale, iq, fit):
    if fit:
        # Use the model for computing the weights.
        a, b = fit
        return 1 / support.abs2(scale - b)
    else:
        # Use the raw data for weighting the fit.
        return support.abs2(iq)


# Computes the relative fit error between the given data and fit, computes the
# error as:
#                                  2
#              SUM | data - model |
#      error = ---------------------
#                              2
#                 SUM | data |
#
# It's looking like this might well be a reasonable estimate of fit quality.
def compute_fit_error(scale, iq, fit):
    model = eval_one_peak(fit, scale)
    error = support.abs2(iq - model).sum()
    sum = support.abs2(iq).sum()
    return error / sum


# Performs one step of the fit_multiple_peaks function below.
def fit_one_peak(scale, iq, ix, fits):
    iq = adjust_iq_with_model(fits, ix, scale, iq)

    # Perform the fit, if this fails discard this and all subsequent fit
    # candidates.
    weights = compute_weights(scale, iq, fits[ix])
    return fit_one_pole(scale, iq, weights)


# Given a list of data ranges fit a one-pole filter to each of the ranges.  The
# fit process is repeated twice for each peak: the first time we perform an
# unweighted fit to the residual data after subtracting previous fits, the
# second time we refine the data by redoing the fit with weighting and
# subtracting the best model from the data.
def fit_multiple_peaks(scale, iq, ranges, fits = None):
    if fits is None:
        fits = [()] * len(ranges)
    else:
        fits = list(fits)

    for ix, range in enumerate(ranges):
        l, r = range
        fit_result = fit_one_peak(scale[l:r], +iq[l:r], ix, fits)
        if fit_result:
            fits[ix] = fit_result

    return fits


def prefit_ranges(config, scale, iq, ranges):
    first_fit = fit_multiple_peaks(scale, iq, ranges)
    fits = numpy.array(fit_multiple_peaks(scale, iq, ranges, first_fit))
    trace = support.Struct(
        first_fit = numpy.array(first_fit), fit = fits)
    return (fits, trace)
