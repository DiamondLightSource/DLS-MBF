# Tune fitter

import numpy

import support
import dd_peaks


def assess_peak(config, scale, range, fit, error):
    left, right = scale[list(range)]
    if left > right:  left, right = right, left

    a, b = fit
    centre = b.real
    width = -b.imag

    # Check peak is in the selected range
    if centre <= left  or  right <= centre:
        print 'peak out of range', left, centre, right
        return False
    elif error >= config.max_error:
        print 'error too large', error, config.max_error
        return False
    elif width < config.min_width or config.max_width < width:
        print 'Peak wrong width', config.min_width, width, config.max_width
        return False
    else:
        return True

def prune_bad_peaks(config, scale, ranges, fits, errors):
    return (ranges, fits, errors)
    result = zip(*[
        (range, fit, error)
        for range, fit, error in zip(ranges, fits, errors)
        if assess_peak(config, scale, range, fit, error)])
    if result:
        return result
    else:
        return ((), (), ())


def fit_peaks_to_ranges(config, scale, iq, ranges):
    fits, errors = support.fit_multiple_peaks(scale, iq, ranges)
    fits, errors = support.fit_multiple_peaks(scale, iq, ranges, fits)
    return prune_bad_peaks(config, scale, ranges, fits, errors)


def extract_good_peaks(scale, ranges, fits):
    def peak_area(ix):
        a, b = fits[ix]
        return support.abs2(a) / -b.imag

    sort_ix = sorted(range(len(fits)), key = peak_area, reverse = True)
    sort_ix = sort_ix[:3]
    return ranges, [fits[ix] for ix in sort_ix]


def refine_fit_ranges(scale, fits, fit_threshold):
    return [
        support.compute_peak_bounds(scale, fit, fit_threshold)
        for fit in fits]


def output_fits(result, fits, errors, max_fits):
    def pad(l):
        l = list(l)
        a = numpy.empty(max_fits)
        a[:] = numpy.nan
        a[:len(l)] = l
        return a

    result.output(
        ar = pad(a.real for a, b in fits),
        ai = pad(a.imag for a, b in fits),
        br = pad(b.real for a, b in fits),
        bi = pad(b.imag for a, b in fits),
        e = pad(errors))

def output_model(result, scale, fits, iq):
    model = support.eval_model(fits, scale)
    result.output(
        i = model.real,
        q = model.imag,
        p = support.abs2(model),
        r = support.abs2(iq - model))


class Fitter:
    def __init__(self, length, max_peaks, fit_peaks = 3):
        self.LENGTH = length
        self.MAX_PEAKS = max_peaks
        self.FIT_PEAKS = fit_peaks


    def process_peak_tune(self, result, scale, iq, ranges):
        ranges, fits, errors = fit_peaks_to_ranges(
            result.config, scale, iq, ranges)
        output_fits(result.fits1, fits, errors, self.MAX_PEAKS)
        output_model(result.model1, scale, fits, iq)

        fits = support.refine_fits(scale, iq, fits)
        output_fits(result.fits2, fits, [], self.MAX_PEAKS)

#         ranges, fits = extract_good_peaks(scale, ranges, fits)
#         ranges = refine_fit_ranges(scale, fits, result.config.fit_threshold)

    #     ranges, fits, errors = fit_peaks_to_ranges(result.config, scale, iq, ranges, fits)
    #     output_model(result.model2, scale, fits, iq)

        return 0, 0, 0


        # Discard all but the three largest peaks.
        discard_small_peaks(second_fit)

        # Extract the final peaks in ascending order of frequency.
    #         struct one_pole final_fits[MAX_PEAKS]
        fitted_peak_count = extract_final_fits(second_fit, final_fits)

        # Finally compute the three peaks and the associated tune.
        status = extract_peak_tune(fitted_peak_count, final_fits, tune, phase)

        return status, tune, phase


    # Computes result of fitting tune to (s, iq)
    def fit_tune(self, result, timestamp, scale, iq):
        power = support.abs2(iq)

        result.set_timestamp(timestamp)
        result.output(
            i = iq.real,
            q = iq.imag,
            power = power[:self.LENGTH],
            scale = scale[:self.LENGTH])

        # Start with an initial set of ranges extracted from the power waveform
        ranges = dd_peaks.get_peak_ranges(result, power, self.MAX_PEAKS)

        status, tune, phase = self.process_peak_tune(result, scale, iq, ranges)
