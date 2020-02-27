# -*- coding: utf-8 -*-

import re
longitudinal_axis_number = 0
re_scope = re.compile("\$\(DEVICE\):\$\(AXIS([01])\):")

def get_scope(pv):
    
    rout = re_scope.match(pv)
    if rout:
        if rout.group(1) == '{:d}'.format(longitudinal_axis_number):
            scope = 'I'
        else:
            scope = 'Q'
    else:
        if pv.find('AXIS01') > 1 :
            scope = 'IQ'
        else:
            scope = 'global'
    return scope


def add_scope_field(dico_tango):
    for pv_name in dico_tango:
        d = dico_tango[pv_name]
        pv = d['pv']
        #print 'pv name..', pv_name, 'scope:', get_scope(pv)
        local_scope = get_scope(pv)
        d['scope'] = local_scope
        if local_scope == 'I':
            d['tango_att_name'] = 'I_'+ d['tango_att_name']
        if local_scope == 'Q':
            d['tango_att_name'] = 'Q_'+ d['tango_att_name']
        if local_scope == 'IQ':
            d['tango_att_name'] = 'IQ_'+ d['tango_att_name']
        #d['tango_att_name'] = d['tango_att_name'][4:]

def keep_one_scope(dico_tango, current_scope):
    keys = dico_tango.keys()
    for pv_name in keys:
        if dico_tango[pv_name]['scope'] != current_scope:
            dico_tango.pop(pv_name)


pv_dot_PROC = [ ]
pv_dot_SCAN = [ ]
e2t_exceptions = { }
