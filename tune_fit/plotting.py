# Plotting of fits

from pkg_resources import require
require('numpy')
require('matplotlib')

import sys
import argparse

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
    fit_in, offset_in = trace.model_in
    offset = trace.offset

    pb = [f[:, 1] for f in all_fits]
    m_in = support.eval_model(scale, fit_in, offset_in)
    mm = support.eval_model(scale, fit, offset)

    pyplot.figure(figsize = (9, 11))

    pyplot.subplot(511)
    pyplot.plot(scale, numpy.abs(iq))
    pyplot.plot(scale, numpy.abs(mm))
    for f in fit_in:
        pyplot.plot(scale, numpy.abs(support.eval_one_peak(f, scale)))
    pyplot.legend(['iq', 'fit'] + ['in%d' % n for n in range(len(fit_in))])

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


class Fitter:
    def __init__(self, samples, max_peaks, plot_each):
        self.max_peaks = max_peaks
        self.plot_each = plot_each
        self.fits = numpy.empty((samples, max_peaks, 2), dtype = numpy.complex)
        self.fits[:] = numpy.nan
        self.n = 0

    def fit_tune(self, scale, iq):
        n = self.n
        print 'fit_tune', n
        self.n = n + 1

        config = support.Struct(max_peaks = self.max_peaks)
        model, trace = tune_fit.fit_tune_model(config, scale, iq)

        if plot_each:
            plot_refine(iq, trace.refine[-1])
            pyplot.show()

        fit = trace.refine[-1].fit
        self.fits[n, :len(fit)] = fit


    def plot_fits(self):
        aa = self.fits[..., 0]
        bb = self.fits[..., 1]

        pyplot.subplot(211)
        pyplot.plot(aa.real, aa.imag, '.')
        pyplot.title('Phase and magnitude')

        pyplot.subplot(212)
        pyplot.plot(bb.real, bb.imag, '.')
        pyplot.title('Poles')
        pyplot.axis('equal')
        pyplot.legend(['p%d' % (n+1) for n in range(self.max_peaks)])

        print numpy.nonzero(bb.imag < -0.003)


# f.set_size_inches(11.69, 8.27)
# f.set_size_inches(8.27, 11.69)
# f.savefig('foo.pdf', papertype = 'a4', orientation = 'portrait')


def parse_args():
    parser = argparse.ArgumentParser(description = 'Replay and plot')
    parser.add_argument('-n', '--peaks', default = 3, type = int,
        help = 'Number of peaks to match')
    parser.add_argument('filename',
        help = 'Name of file to replay')
    parser.add_argument('samples', nargs = '?', default = 0, type = int,
        help = 'Number of samples to replay')
    parser.add_argument('subset', nargs = argparse.REMAINDER, type = int,
        help = 'Individual samples to process')

    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
    print args

    s_iq = replay.load_replay(args.filename, args.samples)
    if args.subset:
        s_iq = [s_iq[ix] for ix in args.subset]

    plot_each = bool(args.subset)

    fitter = Fitter(len(s_iq), args.peaks, plot_each)
    replay.replay_s_iq(s_iq, fitter.fit_tune)

    if not plot_each:
        fitter.plot_fits()
        pyplot.show()
