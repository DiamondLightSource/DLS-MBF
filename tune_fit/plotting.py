# Plotting of fits

from pkg_resources import require
require('numpy')
require('matplotlib')

import sys
import numpy
import matplotlib
# matplotlib.use('PDF')

from matplotlib import pyplot, gridspec

import support
import replay
import dd_peaks
import tune_fit


A4_PORTRAIT  = (8.27, 11.69)
A4_LANDSCAPE = (11.69, 8.27)


LOG_FILE = sys.argv[1]

MAX_N = 100
if len(sys.argv) > 2:
    MAX_N = int(sys.argv[2])
subset = []
if len(sys.argv) > 3:
    subset = map(int, sys.argv[3:])


n = 0


def plot_poles(fit, show = False):
    from matplotlib import pyplot
    pyplot.figure()
    bb = fit[:, 1]
    pyplot.plot(bb.real, bb.imag, 'o')
    c0 = numpy.exp(2j * numpy.pi * numpy.linspace(0, 1, 100))
    for b in bb:
        c = b + b.imag * c0
        pyplot.plot(c.real, c.imag)
    pyplot.axis('equal')
    if show:
        pyplot.show()


def plot_refine(iq, trace):
    from dd_peaks import smooth_waveform

    scale = trace.scale
    fit = trace.fit
    all_fits = trace.all_fits
    fit_in = trace.fit_in
    offset = trace.offset

    pb = [f[:, 1] for f in all_fits]
    m_in = support.eval_model(scale, fit_in)
    mm = support.eval_model(scale, fit, offset)

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
    pyplot.axis('equal')

    pyplot.subplot2grid((5, 2), (1, 1), rowspan = 2)
    for bb in pb[:-1]:
        pyplot.plot(bb.real, bb.imag, '.')
    pyplot.plot(pb[0].real, pb[0].imag, '*')
    pyplot.plot(pb[-1].real, pb[-1].imag, 'o')

    pyplot.subplot2grid((5, 2), (3, 0), colspan = 2)
    pyplot.plot(scale, numpy.abs(iq))
    for f in fit:
        pyplot.plot(scale, numpy.abs(support.eval_one_peak(f, scale)))
    pyplot.legend(['iq'] + ['p%d' % n for n in range(len(fit))])

    res = mm - iq
    res16 = dd_peaks.smooth_waveform(res, 16)
    pyplot.subplot(515)
    pyplot.plot(scale, numpy.abs(res))
    pyplot.plot(dd_peaks.smooth_waveform(scale, 16), numpy.abs(res16))

    plot_poles(fit)

    pyplot.show()


def fit_tune(result, timestamp, scale, iq):
    global n
    print >>sys.stderr, 'fit_tune', n
    n += 1

    config = support.Struct(max_peaks = 6, selection = 0)
    model, trace = tune_fit.fit_tune_model(config, scale, iq)
    plot_refine(iq, trace.refine)

    result.set_timestamp(timestamp)
    tune_fit.update_pvs(config, trace, result)


result = replay.replay_file(LOG_FILE, fit_tune, MAX_N, subset = subset)
# result.print_summary()


def plot_fits(fits):
    pyplot.subplot(211)
    pyplot.plot(fits.ar, fits.ai, '.')
    pyplot.title('Phase and magnitude')

    pyplot.subplot(212)
    pyplot.plot(fits.br, fits.bi, '.')
    pyplot.title('Poles')


f = pyplot.figure()
plot_fits(result.fits1)

f = pyplot.figure()
plot_fits(result.fits2)
pyplot.show()


# f.set_size_inches(11.69, 8.27)
# f.set_size_inches(8.27, 11.69)
# f.savefig('foo.pdf', papertype = 'a4', orientation = 'portrait')
