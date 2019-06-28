#
# Resource backup , created Fri Jun 28 15:07:27 CEST 2019
#

#---------------------------------------------------------
# SERVER Tango2Epics/mfdbk-tunev, Tango2Epics device declaration
#---------------------------------------------------------

Tango2Epics/mfdbk-tunev/DEVICE/Tango2Epics: "sr/d-mtune/v"


# --- sr/d-mtune/v properties

sr/d-mtune/v->ArrayAccessTimeout: 0.3
sr/d-mtune/v->ScalarAccessTimeout: 0.2
sr/d-mtune/v->SubscriptionCycle: 0.4
sr/d-mtune/v->Variables: SR-TMBF:Y:TUNE:CENTRE:HEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_HEIGHT,\ 
                         SR-TMBF:Y:TUNE:CENTRE:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_PHASE,\ 
                         SR-TMBF:Y:TUNE:CENTRE:POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_POWER,\ 
                         SR-TMBF:Y:TUNE:CENTRE:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_TUNE,\ 
                         SR-TMBF:Y:TUNE:CENTRE:VALID*Scalar*Enum*READ_ONLY*ATTRIBUTE*CENTRE_VALID,\ 
                         SR-TMBF:Y:TUNE:CENTRE:WIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_WIDTH,\ 
                         SR-TMBF:Y:TUNE:CONFIG:MAXIMUM_FIT_ERROR_S*Scalar*Double*READ_WRITE*ATTRIBUTE*CONFIG_MAXIMUM_FIT_ERROR_S,\ 
                         SR-TMBF:Y:TUNE:CONFIG:MAX_PEAKS_S*Scalar*Int*READ_WRITE*ATTRIBUTE*CONFIG_MAX_PEAKS_S,\ 
                         SR-TMBF:Y:TUNE:CONFIG:MINIMUM_HEIGHT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*CONFIG_MINIMUM_HEIGHT_S,\ 
                         SR-TMBF:Y:TUNE:CONFIG:MINIMUM_SPACING_S*Scalar*Double*READ_WRITE*ATTRIBUTE*CONFIG_MINIMUM_SPACING_S,\ 
                         SR-TMBF:Y:TUNE:CONFIG:MINIMUM_WIDTH_S*Scalar*Double*READ_WRITE*ATTRIBUTE*CONFIG_MINIMUM_WIDTH_S,\ 
                         SR-TMBF:Y:TUNE:CONFIG:SMOOTHING_S*Scalar*Int*READ_WRITE*ATTRIBUTE*CONFIG_SMOOTHING_S,\ 
                         SR-TMBF:Y:TUNE:FIT_ERROR*Scalar*Double*READ_ONLY*ATTRIBUTE*FIT_ERROR,\ 
                         SR-TMBF:Y:TUNE:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*I,\ 
                         SR-TMBF:Y:TUNE:LAST_ERROR*Scalar*String*READ_ONLY*ATTRIBUTE*LAST_ERROR,\ 
                         SR-TMBF:Y:TUNE:LEFT:DPHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_DPHASE,\ 
                         SR-TMBF:Y:TUNE:LEFT:DTUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_DTUNE,\ 
                         SR-TMBF:Y:TUNE:LEFT:HEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_HEIGHT,\ 
                         SR-TMBF:Y:TUNE:LEFT:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_PHASE,\ 
                         SR-TMBF:Y:TUNE:LEFT:POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_POWER,\ 
                         SR-TMBF:Y:TUNE:LEFT:RHEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_RHEIGHT,\ 
                         SR-TMBF:Y:TUNE:LEFT:RPOWER*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_RPOWER,\ 
                         SR-TMBF:Y:TUNE:LEFT:RWIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_RWIDTH,\ 
                         SR-TMBF:Y:TUNE:LEFT:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_TUNE,\ 
                         SR-TMBF:Y:TUNE:LEFT:VALID*Scalar*Enum*READ_ONLY*ATTRIBUTE*LEFT_VALID,\ 
                         SR-TMBF:Y:TUNE:LEFT:WIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_WIDTH,\ 
                         SR-TMBF:Y:TUNE:MI*Array:4096*Double*READ_ONLY*ATTRIBUTE*MI,\ 
                         SR-TMBF:Y:TUNE:MPOWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*MPOWER,\ 
                         SR-TMBF:Y:TUNE:MQ*Array:4096*Double*READ_ONLY*ATTRIBUTE*MQ,\ 
                         SR-TMBF:Y:TUNE:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*PHASE,\ 
                         SR-TMBF:Y:TUNE:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*POWER,\ 
                         SR-TMBF:Y:TUNE:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*Q,\ 
                         SR-TMBF:Y:TUNE:RESIDUE*Array:4096*Double*READ_ONLY*ATTRIBUTE*RESIDUE,\ 
                         SR-TMBF:Y:TUNE:RIGHT:DPHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_DPHASE,\ 
                         SR-TMBF:Y:TUNE:RIGHT:DTUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_DTUNE,\ 
                         SR-TMBF:Y:TUNE:RIGHT:HEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_HEIGHT,\ 
                         SR-TMBF:Y:TUNE:RIGHT:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_PHASE,\ 
                         SR-TMBF:Y:TUNE:RIGHT:POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_POWER,\ 
                         SR-TMBF:Y:TUNE:RIGHT:RHEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_RHEIGHT,\ 
                         SR-TMBF:Y:TUNE:RIGHT:RPOWER*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_RPOWER,\ 
                         SR-TMBF:Y:TUNE:RIGHT:RWIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_RWIDTH,\ 
                         SR-TMBF:Y:TUNE:RIGHT:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_TUNE,\ 
                         SR-TMBF:Y:TUNE:RIGHT:VALID*Scalar*Enum*READ_ONLY*ATTRIBUTE*RIGHT_VALID,\ 
                         SR-TMBF:Y:TUNE:RIGHT:WIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_WIDTH,\ 
                         SR-TMBF:Y:TUNE:SCALE*Array:4096*Double*READ_ONLY*ATTRIBUTE*SCALE,\ 
                         SR-TMBF:Y:TUNE:SYNCTUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*SYNCTUNE,\ 
                         SR-TMBF:Y:TUNE:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*TUNE

# --- sr/d-mtune/v attribute properties

sr/d-mtune/v/CENTRE_HEIGHT->description: "Peak height"
sr/d-mtune/v/CENTRE_PHASE->description: "Peak phase"
sr/d-mtune/v/CENTRE_PHASE->unit: deg
sr/d-mtune/v/CENTRE_POWER->description: "Peak power"
sr/d-mtune/v/CENTRE_TUNE->description: "Peak centre frequency"
sr/d-mtune/v/CENTRE_VALID->description: "Peak valid"
sr/d-mtune/v/CENTRE_VALID->EnumLabels: Invalid,\ 
                                       Ok
sr/d-mtune/v/CENTRE_WIDTH->description: "Peak width"
sr/d-mtune/v/CONFIG_MAXIMUM_FIT_ERROR_S->description: "Reject overall fit if error this large"
sr/d-mtune/v/CONFIG_MAXIMUM_FIT_ERROR_S->format: %.3f
sr/d-mtune/v/CONFIG_MAX_PEAKS_S->description: "Maximum number of peaks to fit"
sr/d-mtune/v/CONFIG_MAX_PEAKS_S->format: %1d
sr/d-mtune/v/CONFIG_MAX_PEAKS_S->max_value: 5.0
sr/d-mtune/v/CONFIG_MAX_PEAKS_S->min_value: 1.0
sr/d-mtune/v/CONFIG_MINIMUM_HEIGHT_S->description: "Reject peaks shorter than this"
sr/d-mtune/v/CONFIG_MINIMUM_HEIGHT_S->format: %.3f
sr/d-mtune/v/CONFIG_MINIMUM_SPACING_S->description: "Reject peaks closer than this"
sr/d-mtune/v/CONFIG_MINIMUM_SPACING_S->format: %.4f
sr/d-mtune/v/CONFIG_MINIMUM_WIDTH_S->description: "Reject peaks narrower than this"
sr/d-mtune/v/CONFIG_MINIMUM_WIDTH_S->format: %.2f
sr/d-mtune/v/CONFIG_SMOOTHING_S->description: "Degree of smoothing for 2D peak detect"
sr/d-mtune/v/CONFIG_SMOOTHING_S->format: %2d
sr/d-mtune/v/CONFIG_SMOOTHING_S->max_value: 64.0
sr/d-mtune/v/CONFIG_SMOOTHING_S->min_value: 8.0
sr/d-mtune/v/LEFT_DPHASE->description: "Delta phase"
sr/d-mtune/v/LEFT_DPHASE->unit: deg
sr/d-mtune/v/LEFT_DTUNE->description: "Delta tune"
sr/d-mtune/v/LEFT_HEIGHT->description: "Peak height"
sr/d-mtune/v/LEFT_PHASE->description: "Peak phase"
sr/d-mtune/v/LEFT_PHASE->unit: deg
sr/d-mtune/v/LEFT_POWER->description: "Peak power"
sr/d-mtune/v/LEFT_RHEIGHT->description: "Relative height"
sr/d-mtune/v/LEFT_RPOWER->description: "Relative power"
sr/d-mtune/v/LEFT_RWIDTH->description: "Relative width"
sr/d-mtune/v/LEFT_TUNE->description: "Peak centre frequency"
sr/d-mtune/v/LEFT_VALID->description: "Peak valid"
sr/d-mtune/v/LEFT_VALID->EnumLabels: Invalid,\ 
                                     Ok
sr/d-mtune/v/LEFT_WIDTH->description: "Peak width"
sr/d-mtune/v/PHASE->description: "Measured tune phase"
sr/d-mtune/v/PHASE->unit: deg
sr/d-mtune/v/RIGHT_DPHASE->description: "Delta phase"
sr/d-mtune/v/RIGHT_DPHASE->unit: deg
sr/d-mtune/v/RIGHT_DTUNE->description: "Delta tune"
sr/d-mtune/v/RIGHT_HEIGHT->description: "Peak height"
sr/d-mtune/v/RIGHT_PHASE->description: "Peak phase"
sr/d-mtune/v/RIGHT_PHASE->unit: deg
sr/d-mtune/v/RIGHT_POWER->description: "Peak power"
sr/d-mtune/v/RIGHT_RHEIGHT->description: "Relative height"
sr/d-mtune/v/RIGHT_RPOWER->description: "Relative power"
sr/d-mtune/v/RIGHT_RWIDTH->description: "Relative width"
sr/d-mtune/v/RIGHT_TUNE->description: "Peak centre frequency"
sr/d-mtune/v/RIGHT_VALID->description: "Peak valid"
sr/d-mtune/v/RIGHT_VALID->EnumLabels: Invalid,\ 
                                      Ok
sr/d-mtune/v/RIGHT_WIDTH->description: "Peak width"
sr/d-mtune/v/SYNCTUNE->description: "Synchrotron tune"
sr/d-mtune/v/TUNE->description: "Measured tune"

#---------------------------------------------------------
# CLASS Tango2Epics properties
#---------------------------------------------------------

CLASS/Tango2Epics->Description: "A device can be integrated in Tango control system by developing a ",\ 
                                "specific Tango device server software for the device. In situations when",\ 
                                "the Tango device server software is not available for the device, ",\ 
                                "but software support for the EPICS control system is available instead, ",\ 
                                "it is possible to use the Tango2Epics Tango device server to expose ",\ 
                                "the device in Tango system. It serves as a bridge, in form of a Tango device, ",\ 
                                "to EPICS control system. PVaccess device exposes the existing EPICS ",\ 
                                "Process Variables (PVs) of the device in form of Tango device attributes, ",\ 
                                "states, and emulates a preconfigured set of Tango device commands by ",\ 
                                "using the appropriate EPICS PVs. By using the Tango2Epics Tango device, ",\ 
                                "integration can be achieved through configuration only, with no development ",\ 
                                "required. More information can be found in the user manual, located: ",\ 
                                "http://sourceforge.net/p/tango-ds/code/HEAD/tree/DeviceClasses/Communication/Tango2Epics/trunk/doc/Tango2EpicsGateway.pdf."
CLASS/Tango2Epics->doc_url: "http://www.esrf.eu/computing/cs/tango/tango_doc/ds_doc/"
CLASS/Tango2Epics->InheritedFrom: TANGO_BASE_CLASS
CLASS/Tango2Epics->ProjectTitle: "Tango2Epics Tango Device"

# CLASS Tango2Epics attribute properties


