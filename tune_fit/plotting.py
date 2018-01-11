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
import refine
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
    scale = trace.scale
    all_fits = trace.all_fits
    model_in = all_fits[0]
    model_out = all_fits[-1]

    fit_in, _ = model_in
    fit_out, _ = model_out

    pb = [pp[:, 1] for pp, _ in all_fits]
    m_in = refine.eval_model(scale, model_in)
    m_out = refine.eval_model(scale, model_out)

    pyplot.figure(figsize = (9, 11))

    pyplot.subplot(511)
    pyplot.plot(scale, numpy.abs(iq))
    pyplot.plot(scale, numpy.abs(m_out))
    for f in fit_in:
        pyplot.plot(scale, numpy.abs(refine.eval_one_peak(f, scale)))
    pyplot.legend(['iq', 'fit'] + ['in%d' % n for n in range(len(fit_in))])

    pyplot.subplot2grid((5, 2), (1, 0), rowspan = 2)
    pyplot.plot(iq.real, iq.imag)
    pyplot.plot(m_in.real, m_in.imag)
    pyplot.plot(m_out.real, m_out.imag)
    pyplot.legend(['iq', 'in', 'fit'])
    pyplot.axis('equal')

    pyplot.subplot2grid((5, 2), (1, 1), rowspan = 2)
    for bb in pb[:-1]:
        pyplot.plot(bb.real, bb.imag, '.')
    pyplot.plot(pb[0].real, pb[0].imag, '*')
    pyplot.plot(pb[-1].real, pb[-1].imag, 'o')

    pyplot.subplot2grid((5, 2), (3, 0), colspan = 2)
    pyplot.plot(scale, numpy.abs(iq))
    for f in fit_out:
        pyplot.plot(scale, numpy.abs(refine.eval_one_peak(f, scale)))
    pyplot.legend(['iq'] + ['p%d' % n for n in range(len(fit_out))])

    residue = m_out - iq
    pyplot.subplot(515)
    pyplot.plot(scale, numpy.abs(residue))


def plot_dd(trace):
    smoothed = trace.smoothed
    dd = trace.dd
    power = trace.power
    range = trace.range

    pyplot.figure()
    pyplot.subplot(311)
    pyplot.plot(smoothed)
    pyplot.subplot(312)
    pyplot.plot(dd)
    pyplot.subplot(313)
    pyplot.plot(power)
    pyplot.plot(numpy.array(range), power[range], '.-r')


class Fitter:
    def __init__(self, samples, max_peaks, plot_each, plot_all, plot_dd):
        self.max_peaks = max_peaks
        self.plot_each = plot_each
        self.plot_all = plot_all
        self.plot_dd = plot_dd

        self.fits = numpy.empty((samples, max_peaks, 2), dtype = numpy.complex)
        self.fits[:] = numpy.nan
        self.offsets = numpy.empty(samples, dtype = numpy.complex)
        self.offsets[:] = numpy.nan
        self.scale_offsets = numpy.empty(samples)
        self.scale_offsets[:] = numpy.nan
        self.n = 0

    def fit_tune(self, scale, iq):
        n = self.n
        print 'fit_tune', n
        self.n = n + 1

        config = support.Struct(max_peaks = self.max_peaks)
        model, scale_offset, trace = tune_fit.fit_tune_model(config, scale, iq)

        if self.plot_each:
            if self.plot_all:
                steps = trace.refine
            else:
                steps = trace.refine[-1:]
            for step in steps:
                if self.plot_dd and hasattr(step, 'dd_trace'):
                    plot_dd(step.dd_trace)
                plot_refine(iq, step)
            pyplot.show()

        fit, offset = trace.refine[-1].all_fits[-1]
        self.fits[n, :len(fit)] = fit
        self.offsets[n] = offset
        self.scale_offsets[n] = scale_offset


    def plot_fits(self):
        aa = self.fits[..., 0]
        bb = self.fits[..., 1]

        pyplot.figure()
        pyplot.subplot(211)
        pyplot.plot(aa.real, aa.imag, '.')
        pyplot.title('Phase and magnitude')

        pyplot.subplot(212)
        pyplot.plot(bb.real, bb.imag, '.')
        pyplot.title('Poles')
        pyplot.axis('equal')
        pyplot.legend(['p%d' % (n+1) for n in range(self.max_peaks)])

        pyplot.figure()
        pyplot.subplot(311)
        pyplot.plot(bb.real, '.')
        pyplot.legend(['p%d' % (n+1) for n in range(self.max_peaks)])
        pyplot.title('Peak centre')

        pyplot.subplot(312)
        pyplot.semilogy(support.abs2(aa) / -bb.imag, '.')
        pyplot.title('Peak area')

        pyplot.subplot(313)
        pyplot.plot(180 / numpy.pi * numpy.angle(aa), '.')
        pyplot.title('Peak phase')

        print numpy.nonzero(numpy.isnan(self.fits[:,0,0]))[0]


# f.set_size_inches(11.69, 8.27)
# f.set_size_inches(8.27, 11.69)
# f.savefig('foo.pdf', papertype = 'a4', orientation = 'portrait')


def parse_args():
    parser = argparse.ArgumentParser(description = 'Replay and plot')
    parser.add_argument('-n', '--peaks', default = 3, type = int,
        help = 'Number of peaks to match')
    parser.add_argument('-a', '--plot_all',
        default = False, action = 'store_true',
        help = 'Request plotting of all stages of fit')
    parser.add_argument('-d', '--plot_dd',
        default = False, action = 'store_true',
        help = 'Plot derivative fits')
    parser.add_argument('filename',
        help = 'Name of file to replay')
    parser.add_argument('samples', nargs = '?', default = 0, type = int,
        help = 'Number of samples to replay')
    parser.add_argument('subset', nargs = argparse.REMAINDER, type = int,
        help = 'Individual samples to process')

    return parser.parse_args()


def load_and_plot():
    args = parse_args()
    print args

    s_iq = replay.load_replay(args.filename, args.samples)
    if args.subset:
        s_iq = [s_iq[ix] for ix in args.subset]

    plot_each = bool(args.subset) or args.plot_all

    fitter = Fitter(
        len(s_iq), args.peaks, plot_each, args.plot_all, args.plot_dd)
    replay.replay_s_iq(s_iq, fitter.fit_tune)

    if not plot_each:
        fitter.plot_fits()
        pyplot.show()


if __name__ == '__main__':
    load_and_plot()
