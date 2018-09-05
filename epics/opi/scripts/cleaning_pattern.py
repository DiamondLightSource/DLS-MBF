#!/usr/bin/env python2
#-*- coding: utf-8 -*-

from numpy import *

bunch_nb = 992

def gen_cleaning_pattern(sr_mode):
    clean_pattern = zeros((bunch_nb,), dtype=int)
    if sr_mode == '78':
        gap = 61
        clean_pattern[1:1+gap] = 1
        clean_pattern[-gap:] = -1
    elif sr_mode == '16':
        for ii in range(16):
            clean_pattern[62*ii+1:62*(ii+1)] = (2*(ii%2)-1)
    elif sr_mode == '4':
        for ii in range(4):
            clean_pattern[248*ii+1:248*(ii+1)] = (2*(ii%2)-1)
    elif sr_mode == 'H':
        gap_l = 147
        gap_r = 123
        clean_pattern[1:1+gap_l] = 1
        clean_pattern[-gap_r:] = -1
        start = gap_l+1+8
        for ii in range(23):
            clean_pattern[start+ii*31:start+ii*31+23] = (2*(ii%2)-1)
    else:
        raise NameError('SR mode ' + sr_mode + ' invalid')
    return clean_pattern

if __name__ == '__main__':
    clean_pattern = gen_cleaning_pattern('78')
    print clean_pattern
