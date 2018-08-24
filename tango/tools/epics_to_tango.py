#!/bin/env python2
# -*- coding: utf-8 -*-

import re
import argparse
from epics_db import *
from tango_db import *
from config import *


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Generate a ressource file to create Tango devices from epics db file.")
    parser.add_argument(default="global", type=str, help="Scope of the PV (can be global, horizontal or vertical)", dest="current_scope")
    args = parser.parse_args()
    current_scope = args.current_scope
    dev_name = tango_dev_name[current_scope]
    instance_name = tango_instance_name[current_scope]
    
    
    # Make dico_tango_make from db file
    #
    #

    tmbf_db = EPICS_db(db_filename)
    dico_tango_make = tmbf_db.build_tango_dico()

    #dico_tango = {}
    #dico_tango_make.update(Tango_db(dev_name, scope=current_scope))


    # Print for ressource file
    #
    #

    keys = dico_tango_make.keys()
    keys.sort()

    my_str = \
    """#---------------------------------------------------------
# SERVER Tango2Epics/{}, Tango2Epics device declaration
#---------------------------------------------------------

Tango2Epics/{}/DEVICE/Tango2Epics: "{}"


# --- {} properties

{}->Variables: \ """

    # Attribute declaration
    #
    tab = []
    print my_str.format(instance_name, instance_name, dev_name, dev_name, dev_name)
    for pv_name in keys:
        d = dico_tango_make[pv_name]
        if d['scope'] == current_scope:
            pv_name = replace_vars(pv_name)
            t = []
            t += [pv_name]
            t += [d['scal_ar']]
            t += [d['pv_type']]
            t += [d['mode']]
            t += ["ATTRIBUTE"]
            t += [d['tango_att_name']]
            tab += ["{}*{}*{}*{}*{}*{}".format(*t)]
    print ",\\ \n".join(tab)

    print ""
    print "# --- {} attribute properties".format(dev_name)
    print ""

    # Define Attribute Properties
    #
    dico_db = tmbf_db.dico_db
    for pv_name in keys:
        d = dico_tango_make[pv_name]
        scope = d['scope']
        if d['scope'] == current_scope:
            tango_device_name = tango_dev_name[scope]
            tango_att_name = d['tango_att_name']
            
            att_prop_list = ['description', 'EnumLabels', 'unit', 'min_value', 'max_value', 'format']
            for att_prop in att_prop_list:
                if att_prop in d:
                    my_str = tango_device_name + '/' + tango_att_name + '->' + att_prop + ': '
                    if type(d[att_prop]) is str:
                        my_str += '"' + d[att_prop] + '"'
                    else:
                        lst = d[att_prop]
                        my_str += ', '.join('"{}"'.format(elem) for elem in lst)
                    print my_str










