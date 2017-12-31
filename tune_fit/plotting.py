# Plotting of fits

import sys
import numpy
import matplotlib
# matplotlib.use('PDF')

from matplotlib import pyplot

import replay


A4_PORTRAIT  = (8.27, 11.69)
A4_LANDSCAPE = (11.69, 8.27)


LOG_FILE = 'sr23c-di-lmbf-01.tune.log'
# LOG_FILE = 'sr23c-di-tmbf-01.tune.log'
LOG_FILE = 'sr23c-di-tmbf-02.tune.log'

LOG_FILE = sys.argv[1]

MAX_N = 100
if len(sys.argv) > 2:
    MAX_N = int(sys.argv[2])
subset = []
if len(sys.argv) > 3:
    subset = map(int, sys.argv[3:])

result = replay.replay_file(LOG_FILE, MAX_N, subset)

# result.print_summary()


def plot_dd_peaks(peaks):
    M, N = peaks.power.shape
    P = peaks.ix.shape[1]

#     f = pyplot.figure(figsize = A4_PORTRAIT)
    f = pyplot.figure()

    pyplot.subplot(411)
    pyplot.plot(peaks.power.max(0))
    pyplot.plot(peaks.power.min(0))
    pyplot.plot(peaks.power.mean(0))

    pyplot.subplot(412)
    am = numpy.arange(M)
    pyplot.plot(peaks.l, am, '.', markersize = 1)
    pyplot.plot(peaks.r, am, '.', markersize = 1)
    pyplot.xlim((0, N))

    pyplot.subplot(413)
    pyplot.plot(peaks.ix, am, '.', markersize = 1)
    pyplot.xlim((0, N))

    return f

def plot_model(model):
    M, N = model.p.shape

    pyplot.subplot(414)
    pyplot.plot(model.p.T)

def plot_fits(fits):
    pyplot.subplot(211)
    pyplot.plot(fits.ar, fits.ai, '.')
    pyplot.title('Phase and magnitude')

    pyplot.subplot(212)
    pyplot.plot(fits.br, fits.bi, '.')
    pyplot.title('Poles')

#     pyplot.plot(fits.e, '.')


# for style in pyplot.style.available:
#     print style
#     pyplot.style.use(style)
#     f = plot_dd_peaks(result.peak16)

# f = plot_dd_peaks(result.peak16)
# plot_model(result.model1)
# pyplot.show()

import support
if support.plot_refine_fits:
    sys.exit()

f = pyplot.figure()
plot_fits(result.fits1)

f = pyplot.figure()
plot_fits(result.fits2)
pyplot.show()

# f.set_size_inches(11.69, 8.27)
# f.set_size_inches(8.27, 11.69)
# f.savefig('foo.pdf', papertype = 'a4', orientation = 'portrait')
