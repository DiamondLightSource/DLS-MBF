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


def plot_complex(z, *args, **kargs):
    pyplot.plot(z.real, z.imag, *args, **kargs)


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
    plot_complex(iq)
    plot_complex(m_in)
    plot_complex(m_out)
    pyplot.legend(['iq', 'in', 'fit'])
    pyplot.axis('equal')

    pyplot.subplot2grid((5, 2), (1, 1), rowspan = 2)
    for bb in pb[1:-1]:
        plot_complex(bb, '.')
    plot_complex(pb[0], '*')
    plot_complex(pb[-1], 'o')

    pyplot.subplot2grid((5, 2), (3, 0), colspan = 2)
    pyplot.plot(scale, numpy.abs(iq))
    for f in fit_out:
        pyplot.plot(scale, numpy.abs(refine.eval_one_peak(f, scale)))
    pyplot.legend(['iq'] + ['p%d' % n for n in range(len(fit_out))])

    residue = m_out - iq
    pyplot.subplot(515)
    pyplot.plot(scale, numpy.abs(residue))


    pyplot.figure()

    N = len(fit_out)
    aa = fit_out[:, 0]
    bb = fit_out[:, 1]

    pyplot.subplot(211)
    pyplot.title('Peak poles')
    plot_complex(bb.reshape(1, N), 'o')
    pyplot.legend(['p%d' % n for n in range(N)])
    pyplot.gca().set_color_cycle(None)
    c = numpy.exp(2j * numpy.pi * numpy.linspace(0, 1, 100))
    for b in bb:
        cb = b + b.imag * c
        plot_complex(b + b.imag * c)
    pyplot.axis('equal')

    pyplot.subplot(212)
    pyplot.title('Peak phase and magnitude')
    plot_complex(aa.reshape(1, N), 'o')
    pyplot.legend(['p%d' % n for n in range(N)])
    plot_complex(numpy.stack([numpy.zeros(N), aa]), ':k')
    plot_complex(numpy.mean(aa * -bb.imag) / numpy.mean(-bb.imag), 'x')
    pyplot.axis('equal')

    print 'fit', fit_out


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


def plot_fits(fits, tunes, errors):
    max_peaks = fits.shape[1]
    aa = fits[..., 0]
    bb = fits[..., 1]

    pyplot.figure()
    pyplot.title('Phase and magnitude')
    pyplot.subplot(411)
    plot_complex(aa, '.')

    pyplot.subplot(412)
    pyplot.title('Poles')
    plot_complex(bb, '.')
    pyplot.axis('equal')
    pyplot.legend(['p%d' % (n+1) for n in range(max_peaks)])

    pyplot.subplot(413)
    pyplot.title('Measured tunes')
    pyplot.plot(tunes)
    pyplot.legend(['left', 'centre', 'right'])

    pyplot.subplot(414)
    pyplot.title('Relative fit error')
    pyplot.plot(errors)

    pyplot.figure()
    pyplot.subplot(511)
    pyplot.plot(bb.real, '.')
    pyplot.legend(['p%d' % (n+1) for n in range(max_peaks)])
    pyplot.title('Peak centre')

    pyplot.subplot(512)
    pyplot.title('Normalised peak area')
    area = support.abs2(aa) / -bb.imag
    max_area = numpy.nanmax(area, 1)
    pyplot.semilogy(area / max_area[:, None], '.')

    pyplot.subplot(513)
    pyplot.plot(180 / numpy.pi * numpy.angle(aa), '.')
    pyplot.title('Peak phase')

    pyplot.subplot(514)
    N = len(fits)
    dmax = numpy.empty(N)
    dsum = numpy.empty(N)
    for n in range(N):
        bb1, bb2 = numpy.meshgrid(bb[n], bb[n])
        deltas = numpy.abs(bb1.real - bb2.real)
        mask = numpy.zeros(deltas.shape, dtype = bool)
        numpy.fill_diagonal(mask, True)
        deltas = numpy.ma.array(deltas, mask = mask)
        dmax[n] = numpy.min(deltas / numpy.maximum(-bb1.imag, -bb2.imag))
        dsum[n] = numpy.min(deltas / - (bb1.imag + bb2.imag))
    pyplot.plot(dmax)
    pyplot.plot(dsum)
    pyplot.legend(['max', 'sum'])

    pyplot.subplot(515)
    pyplot.title('Normalised peak height')
    height = numpy.abs(aa) / -bb.imag
    max_height = numpy.nanmax(height, 1)
    pyplot.semilogy(height / max_height[:, None], '.')

    print numpy.nonzero(numpy.isnan(fits[:,0,0]))[0]


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
        self.tunes = numpy.empty((samples, 3))
        self.tunes[:] = numpy.nan
        self.errors = numpy.empty(samples)
        self.errors[:] = numpy.nan
        self.n = 0

    def fit_tune(self, scale, iq):
        n = self.n
        print 'fit_tune', n
        self.n = n + 1

        config = support.Config(max_peaks = self.max_peaks)
        trace = tune_fit.fit_tune(config, scale, iq)

        if self.plot_each:
            dd_traces = trace.dd
            refine_traces = trace.refine
            if not self.plot_all:
                dd_traces = dd_traces[-1:]
                refine_traces = refine_traces[-1:]
            if self.plot_dd:
                for dd in dd_traces:
                    plot_dd(dd)
            for refine in refine_traces:
                plot_refine(iq, refine)
            pyplot.show()

        fit, offset = trace.models[-1]
        self.fits[n, :len(fit)] = fit
        self.offsets[n] = offset
        self.scale_offsets[n] = trace.scale_offset
        self.tunes[n] = [
            trace.tune.left.tune, trace.tune.centre.tune, trace.tune.right.tune]
        self.errors[n] = trace.fit_error


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
        plot_fits(fitter.fits, fitter.tunes, fitter.errors)
        pyplot.show()


if __name__ == '__main__':
    load_and_plot()
