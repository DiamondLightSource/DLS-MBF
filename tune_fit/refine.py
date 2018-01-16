# Tune fit refinement

import numpy

import support
import dd_peaks
import prefit



# The following settings control the Levenberg-Marquardt iteration.  There
# should be little or no need to tamper with these.
#   The different lambda up and down factors are as recommended by Transtrum and
# Sethna in "Improvements to the Levenberg-Marquardt algorithm for nonlinear
# least-squares minimization", arXiv:1201.5885.  Their geodesic trick, the main
# focus of this paper, didn't seem to help, but the lamba deltas here do seem to
# speed up convergence.
LAMBDA_UP = 2.0
LAMBDA_DOWN = 1 / 3.0
# If lambda starts to run away then we're not going to converge.
LAMBDA_MAX = 100

# How many steps of L-M refinement to try before bailing out
MAX_STEPS = 20
# Stop refinement when incremental improvement drops to this
REFINE_FRACTION = 1e-3


# Computes model for a single fit
def eval_one_peak(fit, s):
    a, b = fit
    return a / (s - b)


# Evaluates model from a list of fits
def eval_model(scale, model):
    peaks, offset = model
    result = numpy.zeros(scale.shape, dtype = numpy.complex) + offset
    for peak in peaks:
        result += eval_one_peak(peak, scale)
    return result


# This computes the Jacobian derivative matrix dm/dx where m is our model and x
# is fits.  In our model x is a pair of vectors a,b with
#
#               a_i            dm       1        dm        a_i
#   m = SUM_i ------- and so  ---- = ------- ,  ---- = -----------
#             s - b_i         da_i   s - b_i    db_i   (s - b_i)^2
#
def eval_derivative(scale, model):
    peaks, _ = model
    result = []
    for a, b in peaks:
        da = 1 / (scale - b)
        db = a * da * da
        result.extend([da, db])
    result.append(numpy.ones(len(scale)))
    return numpy.array(result)


def step_refine_fits(scale, iq, model, lam):
    w = iq
    e  = w * (eval_model(scale, model) - iq)
    de = w * eval_derivative(scale, model)

    # Convert two part model into a single array
    fits, offset = model
    a = numpy.append(numpy.array(fits).flatten(), offset)

    beta = numpy.inner(de.conj(), e)
    alpha0 = numpy.inner(de.conj(), de)

    Ein2 = support.abs2(e).sum()
    while lam < LAMBDA_MAX:
        alpha = alpha0 + numpy.diag(lam * alpha0.diagonal().real)
        delta = numpy.linalg.solve(alpha, beta)

        a_new = a - delta
        new_fit = a_new[:-1].reshape(-1, 2)
        offset = a_new[-1]

        e_new = w * (eval_model(scale, (new_fit, offset)) - iq)
        Eout2 = support.abs2(e_new).sum()

        if Eout2 >= Ein2:
            lam *= LAMBDA_UP
        else:
            lam *= LAMBDA_DOWN
            change = 1 - Eout2 / Ein2
            return ((new_fit, offset), lam, change)

    return (None, 0, 0)


def refine_fits(scale, iq, fit):
    offset = (iq - eval_model(scale, (fit, 0))).mean()
    model = (fit, offset)

    all_fits = [model]
    lam = 1
    for n in range(MAX_STEPS):
        model, lam, change = step_refine_fits(scale, iq, model, lam)
        if model is None:
            break
        all_fits.append(model)
        if change < REFINE_FRACTION:
            break

    trace = support.Trace(scale = scale, all_fits = all_fits)
    return (model, trace)


# Adds one further pole to the given fit
def add_one_pole(config, scale, iq, model):
    # Compute the residue to fit and take the most peaky peak from the residue
    fit, offset = model
    residue = iq - eval_model(scale, model)
    power = support.abs2(residue)
    (l, r), dd_trace = dd_peaks.get_next_peak(power, config.SMOOTHING)

    # Compute an initial fit
    peak = prefit.fit_one_pole(scale[l:r], residue[l:r], power[l:r])
    if peak is None:
        return (None, dd_trace, ())

    fit = numpy.append(fit, numpy.array(peak).reshape((1, 2)), 0)
    model, refine_trace = refine_fits(scale, iq, fit)

    if model is None: print 'returning failure'
    return (model, dd_trace, refine_trace)
