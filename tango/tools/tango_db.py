# -*- coding: utf-8 -*-

import PyTango
import re
import sys

att_prop_list = ['description', 'EnumLabels', 'unit', 'min_value', 'max_value', 'format']
att_prop_known_list = att_prop_list + ['archive_period', 'archive_abs_change', 'event_period']

db = PyTango.Database()


re1 = re.compile("(.*)\*(.*)\*(.*)\*(.*)\*ATTRIBUTE\*(.*)")

# Make dico_tango from Tango db
#
#
def Tango_db(dev_name, scope=''):
    dev = PyTango.DeviceProxy(dev_name)
    att_def_list = dev.get_property('Variables')['Variables']
    dico_tango = {}
    for att_def in att_def_list:
        rout = re1.match(att_def)
        if rout:
            pv_name = rout.group(1)
            
            # Find PV name
            pv_db = pv_name
            pv_db = pv_db.replace(".PROC", "")
            pv_db = pv_db.replace(".SCAN", "")
            
            d = {}
            d['pv'] = pv_db
            d['pv_name'] = pv_name
            d['scal_ar'] = rout.group(2)
            d['pv_type'] = rout.group(3)
            d['mode'] = rout.group(4)
            d['tango_att_name'] = rout.group(5)
            
            d['scope'] = scope
            
            att_prop_dic = db.get_device_attribute_property(dev_name, 
                    d['tango_att_name'])[d['tango_att_name']]
            
            for att_prop in att_prop_dic.keys():
                if att_prop not in att_prop_known_list:
                    print >> sys.stderr, "Attribute property {} not known"\
                            .format(att_prop)
            
            for att_prop in att_prop_list:
                if att_prop in att_prop_dic:
                    val = att_prop_dic[att_prop]
                    if len(val) == 1:
                        val = val[0]
                    else:
                        val = list(val)
                    d[att_prop] = val
            
            dico_tango[pv_name] = d

    return dico_tango
