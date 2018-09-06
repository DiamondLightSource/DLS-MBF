#
# Resource backup , created Thu Jun 28 12:51:02 CEST 2018
#

#---------------------------------------------------------
# SERVER MacroServer/mfdbk, Door device declaration
#---------------------------------------------------------

MacroServer/mfdbk/DEVICE/Door: "sr/d-mfdbk/door-horizontal",\ 
                               "sr/d-mfdbk/door-vertical"


# --- sr/d-mfdbk/door-horizontal properties

sr/d-mfdbk/door-horizontal->Id: 1
sr/d-mfdbk/door-horizontal->MacroServerName: "sr/d-mfdbk/macro"

# --- sr/d-mfdbk/door-horizontal attribute properties


# --- sr/d-mfdbk/door-vertical properties

sr/d-mfdbk/door-vertical->Id: 1
sr/d-mfdbk/door-vertical->MacroServerName: "sr/d-mfdbk/macro"

# --- sr/d-mfdbk/door-vertical attribute properties


#---------------------------------------------------------
# CLASS Door properties
#---------------------------------------------------------

CLASS/Door->Description: "This class belongs to Sardana project.",\ 
                         "It is able execute Python macro sequences"

# CLASS Door attribute properties


#---------------------------------------------------------
# SERVER MacroServer/mfdbk, MacroServer device declaration
#---------------------------------------------------------

MacroServer/mfdbk/DEVICE/MacroServer: "sr/d-mfdbk/macro"


# --- sr/d-mfdbk/macro properties

sr/d-mfdbk/macro->MacroPath: "/users/dserver/mbf/tango/macros",\ 
                             "/operation/dserver/python/bliss_modules/sardana/macroserver/macros"
sr/d-mfdbk/macro->MaxDoors: 2
sr/d-mfdbk/macro->PythonPath: "/users/dserver/mbf/tango/macros"

# --- sr/d-mfdbk/macro attribute properties


#---------------------------------------------------------
# CLASS MacroServer properties
#---------------------------------------------------------

CLASS/MacroServer->Description: "This class belongs to Sardana project.",\ 
                                "It manages one or several Door devices",\ 
                                "to execute Python macro sequences"

# CLASS MacroServer attribute properties



# --- dserver/MacroServer/mfdbk properties

dserver/MacroServer/mfdbk->__SubDevices: "sr/d-mfdbk/_vertical",\ 
                                         "sr/d-mfdbk/utca-vertical",\ 
                                         "sr/d-mfdbk/utca-global",\ 
                                         "tango://orion:10000/sys/access-control/1",\ 
                                         "sr/d-mfdbk/_horizontal",\ 
                                         "sr/d-mfdbk/utca-horizontal",\ 
                                         "sr/d-mclean/vertical",\ 
                                         "sr/d-mfdbk/cleaning"
