# Preliminary peak discovery by smoothing and second derivative.

import numpy


def smooth_waveform(wf, n):
    wf = wf[:n * (len(wf) / n)]
    return wf.reshape(-1, n).mean(1)

# Smooths waveform by averaging adjacent groups of four samples
def smooth_waveform_4(wf):
    return smooth_waveform(wf, 4)


# Compute second derivative of waveform.  Ensure waveform is padded with zeros
# at both ends to keep the original length.
def compute_dd(wf):
    result = numpy.empty(len(wf))
    result[0] = 0
    result[-1] = 0
    result[1:-1] = numpy.diff(wf, n=2)
    return result


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
def set_peak_result(result, power, dd, peak_data, max_peaks):
    def pad(l):
        a = numpy.zeros(max_peaks)
        a[:len(l)] = l
        return a

    ix, l, r = zip(*peak_data)
    p = power[list(ix)]

    result.output(
        power = power,
        pdd = dd,
        ix = pad(ix),
        l = pad(l),
        r = pad(r),
        v = pad(p))


def process_peak_info(result, power, max_peaks):
    # Compute second derivative of smoothed data for peak detection.
    dd = compute_dd(power)

    # Work through second derivative and extract all peaks.
    peak_data = extract_peaks(power, dd, max_peaks)

    # Convert peak data into presentation waveforms
    set_peak_result(result, power, dd, peak_data, max_peaks)

    return peak_data


# Converts a peak description into scaled left and right boundaries
def peak_info_to_ranges(peak_data, scaling):
    ranges = []
    for ix, l, r in peak_data:
        ranges.append((scaling * l, scaling * (r + 1) - 1))
    return ranges


# Extracts initial set of raw peak ranges from power spectrum
def get_peak_ranges(result, power, max_peaks):
    peak_power_16 = smooth_waveform(power, 16)
    peak_power_64 = smooth_waveform_4(peak_power_16)

    peaks_16 = process_peak_info(result.peak16, peak_power_16, max_peaks)
    peaks_64 = process_peak_info(result.peak64, peak_power_64, max_peaks)

    sel = result.config.sel
    peak_info = [peaks_16, peaks_64][sel]
    scaling = [16, 64][sel]
    return peak_info_to_ranges(peak_info, scaling)
