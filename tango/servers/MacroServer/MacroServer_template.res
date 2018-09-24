#---------------------------------------------------------
# SERVER MacroServer/@@INSTANCE@@, Door device declaration
#---------------------------------------------------------

MacroServer/@@INSTANCE@@/DEVICE/Door: "@@DEVICE_NAME_DOOR_H@@",\ 
                               "@@DEVICE_NAME_DOOR_V@@"


# --- @@DEVICE_NAME_DOOR_H@@ properties

@@DEVICE_NAME_DOOR_H@@->Id: 1
@@DEVICE_NAME_DOOR_H@@->MacroServerName: "@@DEVICE_NAME_MACRO@@"

# --- @@DEVICE_NAME_DOOR_H@@ attribute properties


# --- @@DEVICE_NAME_DOOR_V@@ properties

@@DEVICE_NAME_DOOR_V@@->Id: 1
@@DEVICE_NAME_DOOR_V@@->MacroServerName: "@@DEVICE_NAME_MACRO@@"

# --- @@DEVICE_NAME_DOOR_V@@ attribute properties


#---------------------------------------------------------
# CLASS Door properties
#---------------------------------------------------------

CLASS/Door->Description: "This class belongs to Sardana project.",\ 
                         "It is able execute Python macro sequences"

# CLASS Door attribute properties


#---------------------------------------------------------
# SERVER MacroServer/@@INSTANCE@@, MacroServer device declaration
#---------------------------------------------------------

MacroServer/@@INSTANCE@@/DEVICE/MacroServer: "@@DEVICE_NAME_MACRO@@"


# --- @@DEVICE_NAME_MACRO@@ properties

@@DEVICE_NAME_MACRO@@->MacroPath: "@@DOOR_MACROPATH@@"
@@DEVICE_NAME_MACRO@@->MaxDoors: 2
@@DEVICE_NAME_MACRO@@->PythonPath: "@@DOOR_PYTHONPATH@@"

# --- @@DEVICE_NAME_MACRO@@ attribute properties


#---------------------------------------------------------
# CLASS MacroServer properties
#---------------------------------------------------------

CLASS/MacroServer->Description: "This class belongs to Sardana project.",\ 
                                "It manages one or several Door devices",\ 
                                "to execute Python macro sequences"

# CLASS MacroServer attribute properties

