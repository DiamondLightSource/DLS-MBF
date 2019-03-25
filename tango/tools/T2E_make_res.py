#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import importlib
import argparse
from epics_db import EPICS_db, print_res_file
#from tango_db import Tango_db
import config


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Generate a ressource file " \
            + "to create Tango devices from epics db file.")
    parser.add_argument(type=str, help="IOC name", dest="ioc_name")
    parser.add_argument(type=str, help="EPICS db filename", dest="db_filename")
    parser.add_argument(type=str, help="Scope of the PV " \
            + "(can be global, horizontal or vertical)", dest="current_scope")

    args = parser.parse_args()
    ioc_name = args.ioc_name
    db_filename = args.db_filename
    current_scope = args.current_scope

    T2E_rules = importlib.import_module('T2E_' + ioc_name + '_rules')
    tango_dev_name = getattr(config, ioc_name + '_dev_name')
    tango_instance_name = getattr(config, ioc_name + '_instance_name')
    
    dev_name = tango_dev_name[current_scope]
    instance_name = tango_instance_name[current_scope]

    # Make dico_tango_make from db file
    db = EPICS_db(db_filename, config.vars_users)
    dico_tango_make = db.build_tango_dico(T2E_rules.pv_dot_PROC, 
            T2E_rules.pv_dot_SCAN, T2E_rules.e2t_exceptions)

    # Add scope key, and keep only desired scope
    T2E_rules.add_scope_field(dico_tango_make)
    T2E_rules.keep_one_scope(dico_tango_make, current_scope)

    #dico_tango = {}
    #dico_tango_make.update(Tango_db(dev_name, scope=current_scope))

    # Print for ressource file
    print_res_file(dico_tango_make, instance_name, dev_name)
