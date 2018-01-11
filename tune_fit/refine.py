# Tune fit refinement

import numpy

import support
import dd_peaks
import prefit


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
#     w = support.eval_model(scale, fits, offset)
    w = iq
#     w = 1

    e   = w * (support.eval_model(scale, fits, offset) - iq)
    de  = w * eval_derivative(scale, fits)

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
            e_new = w * (support.eval_model(scale, new_fit, offset) - iq)
            Eout2 = support.abs2(e_new).sum()
            if Eout2 >= Ein2:
                lam *= LAMBDA_UP
                print 'X', lam,
            else:
                lam *= LAMBDA_DOWN
                change = 1 - Eout2 / Ein2
                print 'OK %g -%.3g%% %g' % (lam, 100 * change, Eout2)
                return (new_fit, offset, lam, change)

    raise Exception('Whoops')


MIN_WIDTH = 1e-5
MAX_WIDTH = 5e-2
MAX_WIDTH = 1e-2

CLUSTER_WIDTH = 1.0
# CLUSTER_WIDTH = 0.25
# CLUSTER_WIDTH = 0.75
# CLUSTER_WIDTH = 0.5
# CLUSTER_WIDTH = 0.25
# CLUSTER_WIDTH = 0


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
#                 if abs(c2.real - c1.real) < CLUSTER_WIDTH * min(w1, w2):
#                 if abs(c2.real - c1.real) < CLUSTER_WIDTH * max(w1, w2):
#                 if abs(c2 - c1) < CLUSTER_WIDTH * min(w1, w2):
                if abs(c2 - c1) < CLUSTER_WIDTH * max(w1, w2):
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
            b = 1 / (1 / bin).mean()
            a = b.imag * (ain / bin.imag).sum()
            result.append((a, b))
        else:
            result.append(cluster[0])
    return result


def merge_peaks(fit, changed = False):
    clusters, found = find_clusters(fit)
    if found:
#         plot_poles(fit, True)
        return numpy.array(flatten_clusters(clusters)), True
    else:
        return fit, changed



REFINE_FRACTION = 0.01
REFINE_FRACTION = 1e-4
REFINE_FRACTION = 1e-6
MAX_STEPS = 20
MAX_STEPS = 250
MAX_STEPS = 205

REFINE_FRACTION = 1e-3

def refine_fits(config, scale, iq, fit):
    print 'refine', fit

#     fit, _ = prune_peaks(scale, fit)
    offset = (iq - support.eval_model(scale, fit, 0)).mean()
    model_in = (fit, offset)

    all_fits = [fit]
    lam = 0.1
    lam = 1
    for n in range(MAX_STEPS):
        print n,
        fit, offset, lam, change = step_refine_fits(scale, iq, fit, offset, lam)
#         fit, changed = prune_peaks(scale, fit)
#         fit, changed = merge_peaks(fit, changed)
        changed = False
        all_fits.append(fit)
        if not changed and change < REFINE_FRACTION:
            break

    import sys
    print n, '=>', len(fit)

    model = (fit, offset)
    trace = support.Struct(
        scale = scale, model_in = model_in,
        all_fits = all_fits, fit = fit, offset = offset)


#     import plotting
#     plotting.plot_refine(iq, trace)

    return (model, trace)


# Adds one further pole to the given fit
def add_one_pole(config, scale, iq, model):
    print 'add_one_pole'

    # Compute the residue to fit.
    fit, offset = model
    residue = iq - support.eval_model(scale, fit, offset)

    # Take the most peaky peak from the residue
    smoothing = 64
    power = support.abs2(residue)
    (l, r), trace = dd_peaks.get_next_peak(power, smoothing)

    # Compute an initial fit
    peak = prefit.fit_one_pole(scale[l:r], residue[l:r], power[l:r])

#     from matplotlib import pyplot
#     ss = scale[::smoothing]
#     pyplot.figure()
#     pyplot.subplot(411)
#     pyplot.plot(scale, power)
#     pyplot.plot(ss, trace.smoothed)
#     pyplot.plot(scale[[l, r]], power[[l, r]], '-o')
#     pyplot.subplot(412)
#     pyplot.plot(ss, trace.dd)
#     if mask_in is not None:
#         pyplot.plot(ss, (1-mask_in) * trace.dd)
#     pyplot.subplot(212)
#     pyplot.plot(residue.real, residue.imag)
#     pyplot.plot(residue[l:r].real, residue[l:r].imag)
#     mp = support.eval_one_peak(peak, scale)
#     pyplot.plot(mp[l:r].real, mp[l:r].imag)
#     pyplot.axis('equal')
#     pyplot.show()
# 
#     if -peak[1].imag < MIN_WIDTH:
#         peak = (peak[0], peak[1].real - 1j * MIN_WIDTH)

    fit = numpy.append(fit, numpy.array(peak).reshape((1, 2)), 0)
    return refine_fits(config, scale, iq, fit)
