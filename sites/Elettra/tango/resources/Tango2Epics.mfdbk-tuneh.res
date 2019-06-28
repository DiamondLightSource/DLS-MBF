#
# Resource backup , created Fri Jun 28 15:07:14 CEST 2019
#

#---------------------------------------------------------
# SERVER Tango2Epics/mfdbk-tuneh, Tango2Epics device declaration
#---------------------------------------------------------

Tango2Epics/mfdbk-tuneh/DEVICE/Tango2Epics: "sr/d-mtune/h"


# --- sr/d-mtune/h properties

sr/d-mtune/h->ArrayAccessTimeout: 0.3
sr/d-mtune/h->ScalarAccessTimeout: 0.2
sr/d-mtune/h->SubscriptionCycle: 0.4
sr/d-mtune/h->Variables: SR-TMBF:X:TUNE:CENTRE:HEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_HEIGHT,\ 
                         SR-TMBF:X:TUNE:CENTRE:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_PHASE,\ 
                         SR-TMBF:X:TUNE:CENTRE:POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_POWER,\ 
                         SR-TMBF:X:TUNE:CENTRE:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_TUNE,\ 
                         SR-TMBF:X:TUNE:CENTRE:VALID*Scalar*Enum*READ_ONLY*ATTRIBUTE*CENTRE_VALID,\ 
                         SR-TMBF:X:TUNE:CENTRE:WIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_WIDTH,\ 
                         SR-TMBF:X:TUNE:CONFIG:MAXIMUM_FIT_ERROR_S*Scalar*Double*READ_WRITE*ATTRIBUTE*CONFIG_MAXIMUM_FIT_ERROR_S,\ 
                         SR-TMBF:X:TUNE:CONFIG:MAX_PEAKS_S*Scalar*Int*READ_WRITE*ATTRIBUTE*CONFIG_MAX_PEAKS_S,\ 
                         SR-TMBF:X:TUNE:CONFIG:MINIMUM_HEIGHT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*CONFIG_MINIMUM_HEIGHT_S,\ 
                         SR-TMBF:X:TUNE:CONFIG:MINIMUM_SPACING_S*Scalar*Double*READ_WRITE*ATTRIBUTE*CONFIG_MINIMUM_SPACING_S,\ 
                         SR-TMBF:X:TUNE:CONFIG:MINIMUM_WIDTH_S*Scalar*Double*READ_WRITE*ATTRIBUTE*CONFIG_MINIMUM_WIDTH_S,\ 
                         SR-TMBF:X:TUNE:CONFIG:SMOOTHING_S*Scalar*Int*READ_WRITE*ATTRIBUTE*CONFIG_SMOOTHING_S,\ 
                         SR-TMBF:X:TUNE:FIT_ERROR*Scalar*Double*READ_ONLY*ATTRIBUTE*FIT_ERROR,\ 
                         SR-TMBF:X:TUNE:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*I,\ 
                         SR-TMBF:X:TUNE:LAST_ERROR*Scalar*String*READ_ONLY*ATTRIBUTE*LAST_ERROR,\ 
                         SR-TMBF:X:TUNE:LEFT:DPHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_DPHASE,\ 
                         SR-TMBF:X:TUNE:LEFT:DTUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_DTUNE,\ 
                         SR-TMBF:X:TUNE:LEFT:HEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_HEIGHT,\ 
                         SR-TMBF:X:TUNE:LEFT:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_PHASE,\ 
                         SR-TMBF:X:TUNE:LEFT:POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_POWER,\ 
                         SR-TMBF:X:TUNE:LEFT:RHEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_RHEIGHT,\ 
                         SR-TMBF:X:TUNE:LEFT:RPOWER*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_RPOWER,\ 
                         SR-TMBF:X:TUNE:LEFT:RWIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_RWIDTH,\ 
                         SR-TMBF:X:TUNE:LEFT:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_TUNE,\ 
                         SR-TMBF:X:TUNE:LEFT:VALID*Scalar*Enum*READ_ONLY*ATTRIBUTE*LEFT_VALID,\ 
                         SR-TMBF:X:TUNE:LEFT:WIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_WIDTH,\ 
                         SR-TMBF:X:TUNE:MI*Array:4096*Double*READ_ONLY*ATTRIBUTE*MI,\ 
                         SR-TMBF:X:TUNE:MPOWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*MPOWER,\ 
                         SR-TMBF:X:TUNE:MQ*Array:4096*Double*READ_ONLY*ATTRIBUTE*MQ,\ 
                         SR-TMBF:X:TUNE:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*PHASE,\ 
                         SR-TMBF:X:TUNE:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*POWER,\ 
                         SR-TMBF:X:TUNE:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*Q,\ 
                         SR-TMBF:X:TUNE:RESIDUE*Array:4096*Double*READ_ONLY*ATTRIBUTE*RESIDUE,\ 
                         SR-TMBF:X:TUNE:RIGHT:DPHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_DPHASE,\ 
                         SR-TMBF:X:TUNE:RIGHT:DTUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_DTUNE,\ 
                         SR-TMBF:X:TUNE:RIGHT:HEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_HEIGHT,\ 
                         SR-TMBF:X:TUNE:RIGHT:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_PHASE,\ 
                         SR-TMBF:X:TUNE:RIGHT:POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_POWER,\ 
                         SR-TMBF:X:TUNE:RIGHT:RHEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_RHEIGHT,\ 
                         SR-TMBF:X:TUNE:RIGHT:RPOWER*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_RPOWER,\ 
                         SR-TMBF:X:TUNE:RIGHT:RWIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_RWIDTH,\ 
                         SR-TMBF:X:TUNE:RIGHT:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_TUNE,\ 
                         SR-TMBF:X:TUNE:RIGHT:VALID*Scalar*Enum*READ_ONLY*ATTRIBUTE*RIGHT_VALID,\ 
                         SR-TMBF:X:TUNE:RIGHT:WIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_WIDTH,\ 
                         SR-TMBF:X:TUNE:SCALE*Array:4096*Double*READ_ONLY*ATTRIBUTE*SCALE,\ 
                         SR-TMBF:X:TUNE:SYNCTUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*SYNCTUNE,\ 
                         SR-TMBF:X:TUNE:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*TUNE

# --- sr/d-mtune/h attribute properties

sr/d-mtune/h/CENTRE_HEIGHT->description: "Peak height"
sr/d-mtune/h/CENTRE_PHASE->description: "Peak phase"
sr/d-mtune/h/CENTRE_PHASE->unit: deg
sr/d-mtune/h/CENTRE_POWER->description: "Peak power"
sr/d-mtune/h/CENTRE_TUNE->description: "Peak centre frequency"
sr/d-mtune/h/CENTRE_VALID->description: "Peak valid"
sr/d-mtune/h/CENTRE_VALID->EnumLabels: Invalid,\ 
                                       Ok
sr/d-mtune/h/CENTRE_WIDTH->description: "Peak width"
sr/d-mtune/h/CONFIG_MAXIMUM_FIT_ERROR_S->description: "Reject overall fit if error this large"
sr/d-mtune/h/CONFIG_MAXIMUM_FIT_ERROR_S->format: %.3f
sr/d-mtune/h/CONFIG_MAX_PEAKS_S->description: "Maximum number of peaks to fit"
sr/d-mtune/h/CONFIG_MAX_PEAKS_S->format: %1d
sr/d-mtune/h/CONFIG_MAX_PEAKS_S->max_value: 5.0
sr/d-mtune/h/CONFIG_MAX_PEAKS_S->min_value: 1.0
sr/d-mtune/h/CONFIG_MINIMUM_HEIGHT_S->description: "Reject peaks shorter than this"
sr/d-mtune/h/CONFIG_MINIMUM_HEIGHT_S->format: %.3f
sr/d-mtune/h/CONFIG_MINIMUM_SPACING_S->description: "Reject peaks closer than this"
sr/d-mtune/h/CONFIG_MINIMUM_SPACING_S->format: %.4f
sr/d-mtune/h/CONFIG_MINIMUM_WIDTH_S->description: "Reject peaks narrower than this"
sr/d-mtune/h/CONFIG_MINIMUM_WIDTH_S->format: %.2f
sr/d-mtune/h/CONFIG_SMOOTHING_S->description: "Degree of smoothing for 2D peak detect"
sr/d-mtune/h/CONFIG_SMOOTHING_S->format: %2d
sr/d-mtune/h/CONFIG_SMOOTHING_S->max_value: 64.0
sr/d-mtune/h/CONFIG_SMOOTHING_S->min_value: 8.0
sr/d-mtune/h/LEFT_DPHASE->description: "Delta phase"
sr/d-mtune/h/LEFT_DPHASE->unit: deg
sr/d-mtune/h/LEFT_DTUNE->description: "Delta tune"
sr/d-mtune/h/LEFT_HEIGHT->description: "Peak height"
sr/d-mtune/h/LEFT_PHASE->description: "Peak phase"
sr/d-mtune/h/LEFT_PHASE->unit: deg
sr/d-mtune/h/LEFT_POWER->description: "Peak power"
sr/d-mtune/h/LEFT_RHEIGHT->description: "Relative height"
sr/d-mtune/h/LEFT_RPOWER->description: "Relative power"
sr/d-mtune/h/LEFT_RWIDTH->description: "Relative width"
sr/d-mtune/h/LEFT_TUNE->description: "Peak centre frequency"
sr/d-mtune/h/LEFT_VALID->description: "Peak valid"
sr/d-mtune/h/LEFT_VALID->EnumLabels: Invalid,\ 
                                     Ok
sr/d-mtune/h/LEFT_WIDTH->description: "Peak width"
sr/d-mtune/h/PHASE->description: "Measured tune phase"
sr/d-mtune/h/PHASE->unit: deg
sr/d-mtune/h/RIGHT_DPHASE->description: "Delta phase"
sr/d-mtune/h/RIGHT_DPHASE->unit: deg
sr/d-mtune/h/RIGHT_DTUNE->description: "Delta tune"
sr/d-mtune/h/RIGHT_HEIGHT->description: "Peak height"
sr/d-mtune/h/RIGHT_PHASE->description: "Peak phase"
sr/d-mtune/h/RIGHT_PHASE->unit: deg
sr/d-mtune/h/RIGHT_POWER->description: "Peak power"
sr/d-mtune/h/RIGHT_RHEIGHT->description: "Relative height"
sr/d-mtune/h/RIGHT_RPOWER->description: "Relative power"
sr/d-mtune/h/RIGHT_RWIDTH->description: "Relative width"
sr/d-mtune/h/RIGHT_TUNE->description: "Peak centre frequency"
sr/d-mtune/h/RIGHT_VALID->description: "Peak valid"
sr/d-mtune/h/RIGHT_VALID->EnumLabels: Invalid,\ 
                                      Ok
sr/d-mtune/h/RIGHT_WIDTH->description: "Peak width"
sr/d-mtune/h/SYNCTUNE->description: "Synchrotron tune"
sr/d-mtune/h/TUNE->description: "Measured tune"

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


