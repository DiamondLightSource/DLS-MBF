#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import sys
import os
from numpy import *
from epics_db import *
from tango_db import *
from config import tango_dev_name, vars_users
from T2E_tmbf_rules import pv_dot_PROC, pv_dot_SCAN, e2t_exceptions, tmbf_add_scope_field

db_filename = "../../epics/db/tmbf.db"


class stdout_to_file(object):
    """
This context manager opens a file and redirect stdout to it.
Exit: go back to previous stdout and check if something was written to the file.
If the file is not empty: display the 'not_empty_msg' string,
otherwise delete the file.
    """
    def __init__(self, filename, not_empty_msg):
        self.filename = filename
        self.not_empty_msg = not_empty_msg
        
    def __enter__(self):
        self.file = open(self.filename, 'w')
        self.saveout = sys.stdout
        sys.stdout = self.file

    def __exit__(self, type, value, traceback):
        sys.stdout = self.saveout
        file_is_empty = self.file.tell() == 0
        self.file.close()
        if file_is_empty:
            os.remove(self.filename)
        else:
            print self.not_empty_msg


# Make dico_tango from Tango db
#
#

dico_tango = {}
for scope, dev_name in tango_dev_name.iteritems():
    dico_tango.update(Tango_db(dev_name, scope=scope))


# Make dico_tango_make from db file
#
#

tmbf_db = EPICS_db(db_filename, vars_users)
dico_tango_make = tmbf_db.build_tango_dico(pv_dot_PROC, pv_dot_SCAN,
                    e2t_exceptions)
tmbf_add_scope_field(dico_tango_make)


# TODO: make something in order to check every key
no_check_key = ['pv_name', 'pv_name_abs', 'pv', 'pv_short_suffix']

def equal_list(val1, val2):
    if (type(val1) is list) and (type(val2) is list):
        N = len(val1)
        if len(val2) == N:
            for ii in range(N):
                if val1[ii] != val2[ii]:
                    return False
            return True
        else:
            return False
    else:
        return val1 == val2

def cmp_dico(dico1_name, dico2_name, pv_name):
    dico1 = globals()[dico1_name]
    dico2 = globals()[dico2_name]
    for key, item in dico1[pv_name].iteritems():
        if key in no_check_key:
            continue
        if key not in dico2[pv_name]:
            print key + " not in " + dico2_name + "['", pv_name, "']"
            print ""
            continue
        val1 = dico1[pv_name][key]
        val2 = dico2[pv_name][key]
        if not equal_list(val1, val2):
            print dico2_name + "['", pv_name, "']['", key, "'] != " + dico1_name + "['", pv_name, "']['", key, "']"
            print val2, "!=", val1
            print ""

def cmp_dico2(dico_tango, dico_tango_make, pv_name):
    d = {}
    for key, item in dico_tango[pv_name].iteritems():
        if key in no_check_key:
            continue
        val1 = dico_tango[pv_name][key]
        if key in dico_tango_make[pv_name]:
            val2 = dico_tango_make[pv_name][key]
            if equal_list(val1, val2):
                continue
        d.update({key: val1})
    return d

pv_in_common = []

# Check that everything in the EPICS db is in the Tango db
filename = 'epics_not_in_tango.log'
msg = "At least one EPICS PV is not associated with a Tango attribute.\n" \
        + "See '" + filename + "' for more information.\n"
with stdout_to_file(filename, msg):
    keys = dico_tango_make.keys()
    keys.sort()
    for pv_name in keys:
        if pv_name not in dico_tango:
            print pv_name
        else:
            pv_in_common += [pv_name]

# Check that everything in the Tango db is in the EPICS db
filename = 'tango_not_in_epics.log'
msg = "At least one Tango attribute point to a non-existing EPICS PV.\n" \
        + "See '" + filename + "' for more information.\n"
with stdout_to_file(filename, msg):
    keys = dico_tango.keys()
    keys.sort()
    for pv_name in keys:
        if pv_name not in dico_tango_make:
            print pv_name

# Check differences between current Tango db and generated one
filename = 'diff_tango_epics.log'
msg = "At least one difference was found between current " \
        + "Tango db and generated one.\n" \
        + "See '" + filename + "' for more information.\n"
with stdout_to_file(filename, msg):
    for pv_name in pv_in_common:
        cmp_dico('dico_tango_make', 'dico_tango', pv_name)

# Same thing but different output (dictionnary)
filename = 'diff_tango_epics_dict.log'
msg = "At least one difference was found between current " \
        + "Tango db and generated one.\n" \
        + "See '" + filename + "' for more information.\n"
with stdout_to_file(filename, msg):
    for pv_name in pv_in_common:
        o = cmp_dico2(dico_tango, dico_tango_make, pv_name)
        if len(o) > 0:
            pv_short_suffix = dico_tango_make[pv_name]['pv_short_suffix']
            print "'{}':".format(pv_short_suffix)
            print '    ' + repr(o) + ','
