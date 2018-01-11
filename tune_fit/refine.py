# Tune fit refinement

import numpy

import support
import dd_peaks
import prefit


# Various configuration and tuning settings

MINIMUM_WIDTH = 1e-7
MAXIMUM_SHIFT = 0.5

LAMBDA_UP = 2.0
LAMBDA_DOWN = 1 / 3.0
LAMBDA_MAX = 100

MIN_WIDTH = 1e-5

MAX_STEPS = 20
REFINE_FRACTION = 1e-3

SMOOTHING = 32



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


def assess_delta(a, delta, new_a):
    peak_shift = delta[1:-1:2].real
    new_peak = -new_a[1:-1:2].imag
    return (
        (new_peak > MINIMUM_WIDTH) &
        (numpy.abs(peak_shift) < MAXIMUM_SHIFT)).all()


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
        if not assess_delta(a, delta, a_new):
            lam *= LAMBDA_UP
            print 'U', lam,
        else:
            new_fit = a_new[:-1].reshape(-1, 2)
            offset = a_new[-1]
            e_new = w * (eval_model(scale, (new_fit, offset)) - iq)
            Eout2 = support.abs2(e_new).sum()
            if Eout2 >= Ein2:
                lam *= LAMBDA_UP
                print 'X', lam,
            else:
                lam *= LAMBDA_DOWN
                change = 1 - Eout2 / Ein2
                print 'OK %g -%.3g%% %g' % (lam, 100 * change, Eout2)
                return ((new_fit, offset), lam, change)

    raise Exception('Whoops')


def refine_fits(config, scale, iq, fit):
    print 'refine', fit

    offset = (iq - eval_model(scale, (fit, 0))).mean()
    model = (fit, offset)

    all_fits = [model]
    lam = 1
    for n in range(MAX_STEPS):
        print n,
        model, lam, change = step_refine_fits(scale, iq, model, lam)
        all_fits.append(model)
        if change < REFINE_FRACTION:
            break

    import sys
    print n, '=>', len(fit)

    trace = support.Struct(scale = scale, all_fits = all_fits)
    return (model, trace)


# Adds one further pole to the given fit
def add_one_pole(config, scale, iq, model):
    print 'add_one_pole'

    # Compute the residue to fit.
    fit, offset = model
    residue = iq - eval_model(scale, model)

    # Take the most peaky peak from the residue
    power = support.abs2(residue)
    (l, r), dd_trace = dd_peaks.get_next_peak(power, SMOOTHING)

    # Compute an initial fit
    peak = prefit.fit_one_pole(scale[l:r], residue[l:r], power[l:r])

#     import plotting
#     from matplotlib import pyplot
#     plotting.plot_dd(dd_trace)
#     pyplot.show()

    fit = numpy.append(fit, numpy.array(peak).reshape((1, 2)), 0)
    model, trace = refine_fits(config, scale, iq, fit)
    trace._extend(dd_trace = dd_trace)
    return (model, trace)
