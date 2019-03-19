# -*- coding: utf-8 -*-

import sys
import re
from math import floor

e2t_mode = {
'ai': 'READ_ONLY',
'ao': 'READ_WRITE',
'bi': 'READ_ONLY',
'bo': 'READ_WRITE',
'calc': 'READ_ONLY',
'fanout': 'READ_WRITE',
'longin': 'READ_ONLY',
'longout': 'READ_WRITE',
'mbbi': 'READ_ONLY',
'mbbo': 'READ_WRITE',
'stringin': 'READ_ONLY',
'waveform': 'READ_ONLY'}

re_replace_vars = re.compile('(\$\([^\(\)\s]+\))')

def replace_vars(my_str, vars_defs):
    while True:
        rout = re_replace_vars.search(my_str)
        if rout:
            var_name = rout.group(1)[2:-1]
            if var_name in vars_defs:
                new_str = vars_defs[var_name]
            else:
                print >> sys.stderr, "Variable", rout.group(1), "not defined"
                new_str = ""
            my_str = my_str.replace(rout.group(1), new_str)
        else:
            break
    return my_str

def print_res_file(dico_tango_make, instance_name, dev_name):
    keys = dico_tango_make.keys()
    keys.sort()
    server_name = 'Tango2Epics'

    my_str = \
    """#---------------------------------------------------------
# SERVER {}/{}, {} device declaration
#---------------------------------------------------------

{}/{}/DEVICE/{}: "{}"


# --- {} properties

{}->Variables: \ """

    # Attribute declaration
    #
    args = []
    args += [server_name]
    args += [instance_name]
    args += [server_name]*2
    args += [instance_name]
    args += [server_name]
    args += [dev_name]*3
    print my_str.format(*args)
    tab = []
    for pv_name in keys:
        d = dico_tango_make[pv_name]
        t = []
        t += [d['pv_name_abs']]
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
    for pv_name in keys:
        d = dico_tango_make[pv_name]
        tango_att_name = d['tango_att_name']
        
        att_prop_list = ['description', 'EnumLabels', 'unit', 'min_value',
                'max_value', 'format']
        for att_prop in att_prop_list:
            if att_prop in d:
                my_str = dev_name + '/' + tango_att_name + '->' \
                        + att_prop + ': '
                if type(d[att_prop]) is str:
                    my_str += '"' + d[att_prop] + '"'
                else:
                    lst = d[att_prop]
                    my_str += ', '.join('"{}"'.format(elem) for elem in lst)
                print my_str

class EPICS_db:
    def __init__(self, filename, vars_defs):
        re_db_rec = re.compile("record\((.*),\s+\"(.*)\"")
        re_db_field = re.compile("\s*field\((.*),\s+\"(.*)\"")
    
        f = open(filename, 'r')
        dico_db = {}
        for line in f.readlines():
            rout = re_db_rec.match(line)
            if rout:
                pv = rout.group(2)
                pv_short = pv.replace("$(DEVICE):$(AXIS0):", "")
                pv_short = pv_short.replace("$(DEVICE):$(AXIS1):", "")
                pv_short = pv_short.replace("$(DEVICE):", "")
                d = {}
                dico_db[pv] = d
                d['__type__'] = rout.group(1)
                d['__pv_short__'] = pv_short
                d['__pv_abs__'] = replace_vars(pv, vars_defs)
            else:
                rout = re_db_field.match(line)
                if rout:
                    d[rout.group(1)] = replace_vars(rout.group(2), vars_defs)
        self.dico_db = dico_db
    
    epics_enum_field_b = ["ZNAM", "ONAM"]
    epics_enum_field_o = ["ZRST", "ONST", "TWST", "THST", "FRST", "FVST",
            "SXST", "SVST", "EIST", "NIST", "TEST", "ELST", "TVST", "TTST",
            "FTST", "FFST"]

    def get_enum_list(self, pv):
        d = self.dico_db[pv]
        lst = []
        if d['__type__'] in ['bi', 'bo']:
            epics_enum_field = self.epics_enum_field_b
        else:
            epics_enum_field = self.epics_enum_field_o
        for f in epics_enum_field:
            if f in d:
                lst += [d[f]]
            else:
                break
        if len(lst) == 0:
            print >> sys.stderr, "Error with Enum"
        return lst
    
    def build_tango_dico(self, pv_dot_PROC, pv_dot_SCAN, e2t_exceptions):
        dico = {}
        for pv in self.dico_db.iterkeys():
            pv_short = self.dico_db[pv]['__pv_short__']
            d = None
            if pv_short in pv_dot_PROC:
                pv_name_abs, d = self.get_pv_parameters(pv, e2t_exceptions,
                        suffix='.PROC')
                dico[pv_name_abs] = d
            if pv_short in pv_dot_SCAN:
                pv_name_abs, d = self.get_pv_parameters(pv, e2t_exceptions,
                        suffix='.SCAN')
                dico[pv_name_abs] = d
            if d is None:
                pv_name_abs, d = self.get_pv_parameters(pv, e2t_exceptions)
                dico[pv_name_abs] = d
        return dico
    
    def get_pv_parameters(self, pv, e2t_exceptions, suffix=''):
        dico_db = self.dico_db
        # Find type
        #
        pv_type = None
        if dico_db[pv]['__type__'] == 'waveform':
            if dico_db[pv]['FTVL'] in ['FLOAT', 'DOUBLE']:
                pv_type = 'Double'
            elif dico_db[pv]['FTVL'] in ['CHAR', 'SHORT', 'LONG']:
                pv_type = 'Int'
            else:
                print >> sys.stderr, "Type waveform with field ", \
                        dico_db[pv]['FTVL'], " not supported"
        elif dico_db[pv]['__type__'] in ['bi', 'bo']:
            if 'ZNAM' in dico_db[pv]:
                pv_type = 'Enum'
            else:
                pv_type = 'Int'
        elif dico_db[pv]['__type__'] in ['stringin']:
            pv_type = 'String'
        elif dico_db[pv]['__type__'] in ['ai', 'ao', 'calc']:
            pv_type = 'Double'
        elif dico_db[pv]['__type__'] in ['longin', 'longout', 'fanout']:
            pv_type = 'Int'
        else:
            if 'ZRST' in dico_db[pv]:
                pv_type = 'Enum'
        
        # Find mode
        if dico_db[pv]['__type__'] == 'waveform':
            if pv[-2:] == '_S':
                mode = 'READ_WRITE'
            else:
                mode = 'READ_ONLY'
        else:
            mode = e2t_mode[dico_db[pv]['__type__']]
        
        # Find scalar or array
        if dico_db[pv]['__type__'] == 'waveform':
            if 'NELM' in dico_db[pv]:
                scal_ar = 'Array:{}'.format(dico_db[pv]['NELM'])
        else:
            scal_ar = 'Scalar'
        
        # Find Tango Attribute name
        pv_short = dico_db[pv]['__pv_short__']
        pv_short_suffix = pv_short + suffix
        pv_name = pv
        pv_name += suffix
        pv_name_abs = dico_db[pv]['__pv_abs__'] + suffix
        tango_att_name = pv_short.replace(":", "_")
        
        d = {}
        max_abs = 0
        if 'DESC' in dico_db[pv]:
            d['description'] = dico_db[pv]['DESC']
        if pv_type == 'Enum':
            d['EnumLabels'] = self.get_enum_list(pv)
        if 'EGU' in dico_db[pv]:
            d['unit'] = dico_db[pv]['EGU']
        if 'DRVL' in dico_db[pv]:
            val = float(dico_db[pv]['DRVL'])
            d['min_value'] = "{:.1f}".format(val)
            max_abs = max(max_abs, abs(val))
        if 'DRVH' in dico_db[pv]:
            val = float(dico_db[pv]['DRVH'])
            d['max_value'] = "{:.1f}".format(val)
            max_abs = max(max_abs, abs(val))
        tot = ''
        if max_abs != 0:
            tot = "{:d}".format(len("{:d}".format(int(floor(max_abs))))) 
        if 'PREC' in dico_db[pv]:
            prec = int(dico_db[pv]['PREC'])
            if mode == 'READ_WRITE':
                d['format'] = "%{}.{}f".format(tot, prec)
        if pv_type == 'Int':
            if mode == 'READ_WRITE' and tot != '':
                d['format'] = "%{}d".format(tot)
        
        if suffix == '.SCAN':
            d['EnumLabels'] = ['Passive', 'Event', 'I/O Intr', '10 s', '5 s',
                    '2 s', '1 s', '500 ms', '200 ms', '100 ms']
        
        d['pv'] = pv            # $(DEVICE):$(AXIS0):DAC:MMS:SCAN_S
        d['pv_name'] = pv_name  # $(DEVICE):$(AXIS0):DAC:MMS:SCAN_S.SCAN
        d['pv_name_abs'] = pv_name_abs # SR-TMBF:Y:DAC:MMS:SCAN_S.SCAN
        d['scal_ar'] = scal_ar
        d['pv_type'] = pv_type
        d['mode'] = mode
        d['tango_att_name'] = tango_att_name # DAC_MMS_SCAN_S
        d['pv_short_suffix'] = pv_short_suffix # DAC:MMS:SCAN_S.SCAN
        
        if pv_short_suffix in e2t_exceptions:
            e = e2t_exceptions[pv_short_suffix]
            for kw, item in e.iteritems():
                d[kw] = item
        
        return pv_name_abs, d
