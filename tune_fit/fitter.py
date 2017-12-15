# Tune fitter

import numpy

import pvs
import support


# Given a point at the peak (as determined by DD) track away in both directions
# from this peak so that we span the entire raised peak.  Because the detected
# "peak" may be slightly off peak, we track up before tracking down.  Note that
# this can result in overlapping peak ranges, but this shouldn't matter.
def find_peak_limits(power, peak_ix):
    # Track up and then down from the putative peak to both left and right.
    left = peak_ix
    while left > 0  and  power[left - 1] >= power[left]:
        left -= 1
    while left > 0  and  power[left - 1] <= power[left]:
        left -= 1

    length = len(power)
    right = peak_ix
    while right < length - 1  and  power[right + 1] >= power[right]:
        right += 1
    while right < length - 1  and  power[right + 1] <= power[right]:
        right += 1

    return (left, right)



# Walks through second derivative and extracts all peaks in descending order of
# size.  Returns the list of peaks successfully extracted.
def extract_peaks(power, dd, max_peaks):
    peaks = []
    peak_ix = 0
    peak_marks = numpy.zeros(len(dd), dtype = bool)

    dd = +dd        # Take a local copy of dd so we can modify it
    for ix in range(max_peaks):
        # Find the highest peak.  If there's really nothing to find, stop now
        peak_ix = numpy.argmin(dd)
        if dd[peak_ix] == 0:
            break

        # Discover the bounds of the peak
        left, right = find_peak_limits(power, peak_ix)

        # Erase the points we've just looked at so that we find a fresh peak
        # next time around.
        dd[left:right] = 0

        peaks.append((peak_ix, left, right))

    return peaks


# Converts [(ix, l, r)] into ([ix], [l], [r], [power]) for presentation
def set_peak_pvs(pvs, power, dd, peak_data, max_peaks):
    def pad(l):
        a = numpy.zeros(max_peaks)
        a[:len(l)] = l
        return a

    ix, l, r = zip(*peak_data)
    p = power[list(ix)]

    pvs.emit(
        power = power,
        pdd = dd,
        ix = pad(ix),
        l = pad(l),
        r = pad(r),
        v = pad(p))


def process_peak_info(pvs, power, max_peaks):
    # Compute second derivative of smoothed data for peak detection.
    dd = support.compute_dd(power)

    # Work through second derivative and extract all peaks.
    peak_data = extract_peaks(power, dd, max_peaks)

    # Convert peak data into presentation waveforms
    set_peak_pvs(pvs, power, dd, peak_data, max_peaks)

    return peak_data


# Converts a peak description into scaled left and right boundaries
def peak_info_to_ranges(peak_data, scaling):
    ranges = []
    for ix, l, r in peak_data:
        ranges.append((scaling * l, scaling * (r + 1) - 1))
    return ranges


peak_fit_threshold = 0.2
max_fit_error = 0.6
min_peak_width = 1e-6
max_peak_width = 5e-3


def assess_peak(scale, range, fit, error):
    left, right = scale[list(range)]
    if left > right:  left, right = right, left

    a, b = fit
    centre = b.real
    width = -b.imag

    # Check peak is in the selected range
    if centre <= left  or  right <= centre:
#         print 'peak out of range'
        return False
    elif error >= max_fit_error:
#         print 'error too large'
        return False
    elif width < min_peak_width or max_peak_width < width:
        print 'Peak wrong width', min_peak_width, width, max_peak_width
        return False
    else:
        return True

def prune_bad_peaks(scale, ranges, fits, errors):
    result = zip(*[
        (range, fit, error)
        for range, fit, error in zip(ranges, fits, errors)
        if assess_peak(scale, range, fit, error)])
    if result:
        return result
    else:
        return ((), (), ())


def fit_peaks(scale, iq, ranges, fits = None):
    fits, errors = support.fit_multiple_peaks(scale, iq, ranges, fits)
    return prune_bad_peaks(scale, ranges, fits, errors)



def extract_good_peaks(scale, ranges, fits):
    return ranges, fits


def refine_fit_ranges(scale, fits):
    return [
        support.compute_peak_bounds(scale, fit, peak_fit_threshold)
        for fit in fits]


def output_model(pvs, scale, fits):
    model = support.eval_model(fits, scale)
    pvs.emit(
        i = model.real,
        q = model.imag,
        p = support.abs2(model))


def process_peak_tune(pvs, scale, iq, ranges):
    ranges, fits, errors = fit_peaks(scale, iq, ranges)
    output_model(pvs.model1, scale, fits)

    ranges, fits = extract_good_peaks(scale, ranges, fits)
    ranges = refine_fit_ranges(scale, fits)

    ranges, fits, errors = fit_peaks(scale, iq, ranges, fits)
    output_model(pvs.model2, scale, fits)

    return 0, 0, 0

    extract_peak_ranges(length, info, first_fit)
    fit_peaks(sweep, tune_scale, first_fit, false)

    # Refine the fit.
    extract_good_peaks(length, tune_scale, first_fit, second_fit)
    fit_peaks(sweep, tune_scale, second_fit, true)

    # Discard all but the three largest peaks.
    discard_small_peaks(second_fit)

    # Extract the final peaks in ascending order of frequency.
#         struct one_pole final_fits[MAX_PEAKS]
    fitted_peak_count = extract_final_fits(second_fit, final_fits)

    # Finally compute the three peaks and the associated tune.
    status = extract_peak_tune(fitted_peak_count, final_fits, tune, phase)

    return status, tune, phase


class Fitter:
    LENGTH = 4096
    MAX_PEAKS = 5

    def __init__(self, prefix):
        self.pvs = pvs.publish_pvs(prefix, self.LENGTH, self.MAX_PEAKS)

    # Extracts initial set of raw peak ranges from power spectrum
    def get_peak_ranges(self, power):
        peak_power_4  = support.smooth_waveform_4(power)
        peak_power_16 = support.smooth_waveform_4(peak_power_4)
        peak_power_64 = support.smooth_waveform_4(peak_power_16)

        peaks_16 = process_peak_info(
            self.pvs.peak16, peak_power_16, self.MAX_PEAKS)
        peaks_64 = process_peak_info(
            self.pvs.peak64, peak_power_64, self.MAX_PEAKS)

        sel = self.pvs.config.sel
        peak_info = [peaks_16, peaks_64][sel]
        scaling = [16, 64][sel]
        return peak_info_to_ranges(peak_info, scaling)

    # Computes result of fitting tune to (s, iq)
    def fit_tune(self, timestamp, scale, iq):
        power = support.abs2(iq)

        self.pvs.set_timestamp(timestamp)
        self.pvs.emit(
            i = iq.real,
            q = iq.imag,
            power = power[:self.LENGTH],
            scale = scale[:self.LENGTH])

        ranges = self.get_peak_ranges(power)
        status, tune, phase = process_peak_tune(self.pvs, scale, iq, ranges)
