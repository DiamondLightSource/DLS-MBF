# Preliminary peak discovery by smoothing and second derivative.

import numpy

from support import Struct


def smooth_waveform(wf, n):
    wf = wf[:n * (len(wf) / n)]
    return wf.reshape(-1, n).mean(1)



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


# Computes a list of peak candidates in the given data by a three stage process:
#   1.  Smooth and decimate the data by the given factor
#   2.  Compute the second derivative of the smoothed and decimated data
#   3.  Extract peaks from second derivative
def compute_peaks(power, smoothing, max_peaks):
    smoothed = smooth_waveform(power, smoothing)
    dd = compute_dd(smoothed)
    peaks = extract_peaks(smoothed, dd, max_peaks)

    return (peaks, Struct(smoothed = smoothed, dd = dd, peaks = peaks))


# Converts a peak description into scaled left and right boundaries
def peak_info_to_ranges(peaks, scaling):
    ranges = []
    for ix, l, r in peaks:
        ranges.append((scaling * l, scaling * (r + 1) - 1))
    return ranges


def get_next_peak(power, smoothing):
    smoothed = smooth_waveform(power, smoothing)
    dd = compute_dd(smoothed)

    peak_ix = numpy.argmin(dd)

    left, right = find_peak_limits(smoothed, peak_ix)

    range = [smoothing * left, smoothing * (right + 1) - 1]
    trace = Struct(
        power = power,
        smoothing = smoothing,
        smoothed = smoothed,
        dd = dd,
        ix = peak_ix, range = range)

#     from matplotlib import pyplot
#     saxis = numpy.arange(len(smoothed)) * smoothing + 0.5 * smoothing
#     pyplot.figure()
#     pyplot.plot(power)
#     pyplot.plot(saxis, smoothed)
#     pyplot.plot(saxis[[left, right]], smoothed[[left, right]], 'o-')
#     pyplot.plot(saxis[peak_ix], smoothed[peak_ix], 'o')
#     pyplot.show()

    return (range, trace)
