# Peak prefitting
# Fitting one-pole model to IQ.

import numpy

from support import abs2


# Fitting one pole filter to IQ data.  Given waveforms scale[] and wf[], which
# we write here as s[] and iq[], this function computes complex parameters a and
# b to minimise the fitting error for the model
#
#               a
#      z(s) = -----    with nominal error term  en = z - iq
#             s - b    ie, en[i] = z(s[i]) - iq[i] .
#
# As a matter of practicality, minimising this error term requires an expensive
# least squares minimisation, so instead we fudge this by multiplying through by
# (s - b) and a weighting factor w to get the fitted error term
#
#      e = w . (s - b) . en = w . (a + b . iq - iq . s) .
#
# We can minimise E = ||e||^2 = sum_i |e[i]|^2 by solving the overdetermined
# matrix equation
#
#      W M x = W y     where
#          M[i,.] = (1, iq[i]), x = [a; b], y[i] = s[i] . iq[i], W = diag(w).
#
# It turns out that for complex M, x, y, we can solve this by solving the fully
# determined equation
#
#      M^H W M x = M^H W y
#
# This is easily multiplied out to produce the equations:
#
#      [ S(w)      S(w iq)     ] [a] = [ S(w s iq)     ]
#      [ S(w iq)*  S(w |iq|^2) ] [b]   [ S(w s |iq|^2) ]
#
# and this is of course easy to solve for (a,b) by inverting the 2x2 matrix.
#
# Note however that the solution here minimises w.(s-b).en, and without a
# compensating weight this solution gives too much emphasis to points further
# away from the centre frequency b.  This can be fixed by performing the fit
# twice: once with w = 1 and a second time with w = 1 / |s - b|^2; assuming the
# first fit is acceptable, this second fit will refine the fit with more
# emphasis on the points nearer the centre frequency.
#
# The inverse of M^H W M is
#
#      [a] = 1/D [ S(w |iq|^2)  -S(w iq) ] [ S(w s iq)     ]
#      [b]       [ -S(w iq*)    S(w)     ] [ S(w s |iq|^2) ]
# where
#      D = S(2) S(2 |iq|^2) - |S(w iq)|^2
def fit_one_pole(scale, iq, weights):
    # Compute the components of M^H W M and M^H W y.
    iq2 = abs2(iq)

    S_w       = weights.sum()                   # S w
    S_w_iq    = (weights * iq).sum()            # S w iq
    S_w_iq2   = (weights * iq2).sum()           # S w |iq|^2
    S_w_s_iq  = (weights * iq * scale).sum()    # S w s iq
    S_w_s_iq2 = (weights * iq2 * scale).sum()   # S w s |iq|^2

    # Do the inversion by hand
    det = S_w * S_w_iq2 - abs2(S_w_iq)
    a = (S_w_iq2 * S_w_s_iq - S_w_iq * S_w_s_iq2) / det
    b = (S_w * S_w_s_iq2 - numpy.conj(S_w_iq) * S_w_s_iq) / det
    return numpy.array([a, b])
