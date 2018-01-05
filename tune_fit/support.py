# Helper functions for tune fitting

import numpy


def smooth_waveform(wf, n):
    wf = wf[:n * (len(wf) / n)]
    return wf.reshape(-1, n).mean(1)

# On the assumption that scale is sorted returns an index into scale that is,
# hopefully, close to the given tune.
def tune_to_index(scale, tune):
    if scale[-1] < scale[0]:
        scale = scale[::-1]
    return numpy.searchsorted(scale, tune)


# Computes a peak range [left<right] corresponding to the given fit and
# threshold.  Involves searching the tune_scale to convert frequencies into
# index.
def compute_peak_bounds(scale, fit, threshold):
    # Given z = a/(s-b) with b = s_0 + i w we have
    #                    2                          2
    #         2       |a|                    2   |a|
    #      |z|  = -------------  and  max |z|  = ----
    #                    2    2                    2
    #             (s-s_0)  + w                    b
    #
    # Thus given a threshold k we solve for |z|^2 = k max |z|^2 as equal to
    #                     (1 - k)
    #      s_0 +- w * sqrt(-----)
    #                     (  k  )
    #
    a, b = fit
    width = -b.imag
    centre = b.real
    delta = width * numpy.sqrt((1 - threshold) / threshold)
    left  = centre + delta
    right = centre - delta

    left  = tune_to_index(scale, left)
    right = tune_to_index(scale, right)
    if left > right: left, right = right, left
    return (left, right)


# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# Fitting one-pole model to IQ.


def abs2(z):
    return z.real ** 2 + z.imag ** 2


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

def fit_one_pole(scale, iq, weights):
    # Compute the components of M^H W M and M^H W y.
    iq2 = abs2(iq)
    S_w       = weights.sum()                   # S w
    S_w_iq    = (weights * iq).sum()            # S w iq
    S_w_iq2   = (weights * iq2).sum()           # S w |iq|^2
    S_w_s_iq  = (weights * iq * scale).sum()    # S w s iq
    S_w_s_iq2 = (weights * iq2 * scale).sum()   # S w s |iq|^2

    # Do the inversion by hand
    det = S_w * S_w_iq2 - abs2(S_w_iq)
    # Check for a sensible fit, otherwise fail.
    if len(iq) >= 2  and  abs(det) > S_w:
        a = (S_w_iq2 * S_w_s_iq - S_w_iq * S_w_s_iq2) / det
        b = (S_w * S_w_s_iq2 - numpy.conj(S_w_iq) * S_w_s_iq) / det
        return (a, b)
    else:
        return ()


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
        return 1 / abs2(scale - b)
    else:
        # Use the raw data for weighting the fit.
        return abs2(iq)


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
    error = abs2(iq - model).sum()
    sum = abs2(iq).sum()
    return error / sum


# Performs one step of the fit_multiple_peaks function below.
def fit_one_peak(scale, iq, ix, fits):
    iq = adjust_iq_with_model(fits, ix, scale, iq)

    # Perform the fit, if this fails discard this and all subsequent fit
    # candidates.
    weights = compute_weights(scale, iq, fits[ix])
    fit = fit_one_pole(scale, iq, weights)
    if fit:
        return (fit, compute_fit_error(scale, iq, fit))
    else:
        return ()


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
    errors = numpy.zeros(len(ranges))

    result = []
    for ix, range in enumerate(ranges):
        l, r = range
        fit_result = fit_one_peak(scale[l:r], +iq[l:r], ix, fits)
        if fit_result:
            fits[ix], errors[ix] = fit_result
            result.append(fit_result)
#         else:
#             # Return the fits that were successful.
#             return fits[:ix], errors[:ix]

    return zip(*result)



# A more direct version of the above which doesn't try tricks with adjusting the
# data.
def fit_multiple_peaks2(scale, iq, ranges):
    fits = []
    errors = []

    for range in ranges:
        range = slice(*range)
        fit_s = scale[range]
        fit_iq = iq[range]
        fit = fit_one_pole(fit_s, fit_iq, abs2(fit_iq))
        if not fit:
            break
        error = compute_fit_error(fit_s, fit_iq, fit)
        fits.append(fit)
        errors.append(error)
    return (fits, errors)


MINIMUM_WIDTH = 1e-7
MAXIMUM_SHIFT = 0.5

def assess_delta(a, delta, new_a):
    peak_shift = delta[1:-1:2].real
    new_peak = -new_a[1:-1:2].imag
    return (
        (new_peak > MINIMUM_WIDTH) &
        (numpy.abs(peak_shift) < MAXIMUM_SHIFT)).all()


LAMBDA_UP = 2.0
LAMBDA_DOWN = 1 / 3.0
LAMBDA_MAX = 100


# This computes the Jacobian derivative matrix dm/dx where m is our model and x
# is fits.  In our model x is a pair of vectors a,b with
#
#               a_i            dm       1        dm        a_i
#   m = SUM_i ------- and so  ---- = ------- ,  ---- = -----------
#             s - b_i         da_i   s - b_i    db_i   (s - b_i)^2
#
def eval_derivative(scale, fits):
    result = []
    for a, b in fits:
        da = 1 / (scale - b)
        db = a * da * da
        result.extend([da, db])
    result.append(numpy.ones(len(scale)))
    return numpy.array(result)


AVMAX = 1

def step_refine_fits(scale, iq, fits, offset, lam):
    w = eval_model(scale, fits, offset)
#     w = iq
#     w = 1

    e   = w * (eval_model(scale, fits, offset) - iq)
    de  = w * eval_derivative(scale, fits)

    a = numpy.append(numpy.array(fits).flatten(), offset)

    beta = numpy.inner(de.conj(), e)
    alpha0 = numpy.inner(de.conj(), de)

    Ein2 = abs2(e).sum()
    while lam < LAMBDA_MAX:
        alpha = alpha0 + numpy.diag(lam * alpha0.diagonal().real)
        delta = numpy.linalg.solve(alpha, beta)

        a_new = a - delta
        if not assess_delta(a, delta, a_new):
            lam *= LAMBDA_UP
            print 'U', lam,
        else:
            new_fit = a_new[:-1].reshape(-1, 2)
            offset = a_new[-1]
            e_new = w * (eval_model(scale, new_fit, offset) - iq)
            Eout2 = abs2(e_new).sum()
            if Eout2 >= Ein2:
                lam *= LAMBDA_UP
                print 'X', lam,
            else:
                lam *= LAMBDA_DOWN
                change = 1 - Eout2 / Ein2
                print 'OK %g -%.3g%%' % (lam, 100 * change)
                return (new_fit, offset, lam, change)

    raise Exception('Whoops')


MIN_WIDTH = 2e-5
MAX_WIDTH = 5e-2
MAX_WIDTH = 1e-2

CLUSTER_WIDTH = 1.0
# CLUSTER_WIDTH = 0.25
# CLUSTER_WIDTH = 0.75
# CLUSTER_WIDTH = 0.5
# CLUSTER_WIDTH = 0.25


def prune_peaks(scale, fit):
    result = []
    changed = False

    left = scale[0]
    right = scale[-1]
    if left > right: left, right = right, left

    for a, b in fit:
        centre = b.real
        width = -b.imag
        if width < MIN_WIDTH or width > MAX_WIDTH:
            print 'dropping: width =', width
            changed = True
        elif centre < left + width or centre > right - width:
            print 'dropping: centre = ', centre
            changed = True
        else:
            result.append((a, b))

    return numpy.array(result), changed


def find_clusters(fit):
    result = []
    cluster_found = False
    for ab in fit:
        c1 = ab[1]
        w1 = -ab[1].imag
        for cluster in result:
            # See if we're close to any peaks in any existing cluster
            found = False
            for ab2 in cluster:
                c2 = ab2[1]
                w2 = -ab2[1].imag
                if abs(c2.real - c1.real) < CLUSTER_WIDTH * min(w1, w2):
#                 if abs(c2.real - c1.real) < CLUSTER_WIDTH * max(w1, w2):
#                 if abs(c2 - c1) < CLUSTER_WIDTH * min(w1, w2):
                    cluster.append(ab)
                    found = True
                    break
            if found:
                cluster_found = True
                break
        else:
            result.append([ab])
    return result, cluster_found


def flatten_clusters(clusters):
    result = []
    for cluster in clusters:
        if len(cluster) > 1:
            print 'group', len(cluster), 'poles', cluster
            ain, bin = numpy.array(cluster).T
            b = bin.mean()
#             a = ain.sum()
            a = b.imag * (ain / bin.imag).sum()
            result.append((a, b))
        else:
            result.append(cluster[0])
    return result


def merge_peaks(fit, changed = False):
    clusters, found = find_clusters(fit)
    if found:
        return numpy.array(flatten_clusters(clusters)), True
    else:
        return fit, changed


plot_refine_fits = False
plot_refine_fits = True


REFINE_FRACTION = 0.01
REFINE_FRACTION = 1e-4
REFINE_FRACTION = 1e-6
MAX_STEPS = 20
MAX_STEPS = 250
MAX_STEPS = 205

def refine_fits(scale, iq, fit):
    fit_in = fit

    fit, _ = prune_peaks(scale, fit)
    offset = (iq - eval_model(scale, fit, 0)).mean()

    all_fits = [fit]
    lam = 0.1
    lam = 1
    for n in range(MAX_STEPS):
        print n,
        fit, offset, lam, change = step_refine_fits(scale, iq, fit, offset, lam)
        fit, changed = prune_peaks(scale, fit)
        fit, changed = merge_peaks(fit, changed)
        all_fits.append(fit)
        if not changed and change < REFINE_FRACTION:
            break
    print n, '=>', len(fit)


    print fit[:,1]

#     assert len(fit) == 4

    r = fit[:,1].real
    i = fit[:,1].imag
#     if ((r > 80.278) & (i < -0.0025)).any():
    if (r < 80.26).any():
        print 'About to bail out'
        import os
#         os._exit(0)


    if not plot_refine_fits:
        return fit


    from matplotlib import pyplot, gridspec
    from dd_peaks import smooth_waveform

    pb = [f[:, 1] for f in all_fits]
    m_in = eval_model(scale, fit_in)
    mm = eval_model(scale, fit, offset)

    pyplot.figure(figsize = (9, 11))

    pyplot.subplot(511)
    pyplot.plot(scale, numpy.abs(iq))
    pyplot.plot(scale, numpy.abs(m_in))
    pyplot.plot(scale, numpy.abs(mm))
    pyplot.legend(['iq', 'in', 'fit'])

    pyplot.subplot2grid((5, 2), (1, 0), rowspan = 2)
    pyplot.plot(iq.real, iq.imag)
    pyplot.plot(m_in.real, m_in.imag)
    pyplot.plot(mm.real, mm.imag)
    pyplot.legend(['iq', 'in', 'fit'])

    pyplot.subplot2grid((5, 2), (1, 1), rowspan = 2)
    for bb in pb[:-1]:
        pyplot.plot(bb.real, bb.imag, '.')
    pyplot.plot(pb[0].real, pb[0].imag, '*')
    pyplot.plot(pb[-1].real, pb[-1].imag, 'o')

    pyplot.subplot2grid((5, 2), (3, 0), colspan = 2)
    pyplot.plot(scale, numpy.abs(iq))
    for f in fit:
        pyplot.plot(scale, numpy.abs(eval_one_peak(f, scale)))
    pyplot.legend(['iq'] + ['p%d' % n for n in range(len(fit))])

    res = mm - iq
    res16 = smooth_waveform(res, 16)
    pyplot.subplot(515)
    pyplot.plot(scale, numpy.abs(res))
    pyplot.plot(smooth_waveform(scale, 16), numpy.abs(res16))



    pyplot.show()
    return fit


    pyplot.figure()
    for bb in pb[:-1]:
        pyplot.plot(bb.real, bb.imag, '.')
    pyplot.plot(pb[0].real, pb[0].imag, '*')
    pyplot.plot(pb[-1].real, pb[-1].imag, 'o')

    pyplot.figure()
    pa = [f[:, 0] for f in all_fits]
    for aa in pa[:-1]:
        pyplot.plot(aa.real, aa.imag, '.')
    pyplot.plot(pa[0].real, pa[0].imag, '*')
    pyplot.plot(pa[-1].real, pa[-1].imag, 'o')

    areas = abs2(fit[:,0]) / - fit[:,1].imag
    print 'areas', areas / areas.max()


    pyplot.show()
    return fit
