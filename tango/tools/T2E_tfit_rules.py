# -*- coding: utf-8 -*-

import re
from config import horizontal_axis_number

re_scope = re.compile("\$\(DEVICE\):\$\(AXIS([01])\):")

def get_scope(pv):
    rout = re_scope.match(pv)
    if rout:
        if rout.group(1) == '{:d}'.format(horizontal_axis_number):
            scope = 'horizontal'
        else:
            scope = 'vertical'
    else:
        scope = 'global'
    return scope

def add_scope_field(dico_tango):
    for pv_name in dico_tango:
        d = dico_tango[pv_name]
        pv = d['pv']
        d['scope'] = get_scope(pv)
        d['tango_att_name'] = d['tango_att_name'][5:]

def keep_one_scope(dico_tango, current_scope):
    keys = dico_tango.keys()
    for pv_name in keys:
        if dico_tango[pv_name]['scope'] != current_scope:
            dico_tango.pop(pv_name)


pv_dot_PROC = [ ]
pv_dot_SCAN = [ ]
e2t_exceptions = { }
