# Preliminary peak discovery by smoothing and second derivative.

import numpy

import support


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
# "peak" may be slightly off peak, we track up before tracking down.
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


def get_next_peak(power, smoothing, exclude):
    smoothed = smooth_waveform(power, smoothing)
    dd = compute_dd(smoothed)

    # Knock out the exclusion regions
    for l, r in exclude / smoothing:
        dd[l:r] = 0

    peak_ix = numpy.argmin(dd)
    left, right = find_peak_limits(smoothed, peak_ix)
    range = [smoothing * left, smoothing * (right + 1) - 1]

    trace = support.Trace(
        power = power,
        smoothing = smoothing,
        smoothed = smoothed,
        dd = dd,
        ix = peak_ix, range = range)

    return (range, trace)
