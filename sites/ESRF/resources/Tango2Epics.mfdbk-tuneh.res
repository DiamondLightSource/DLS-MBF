#
# Resource backup , created Thu Jun 28 12:47:53 CEST 2018
#

#---------------------------------------------------------
# SERVER Tango2Epics/mfdbk-tuneh, Tango2Epics device declaration
#---------------------------------------------------------

Tango2Epics/mfdbk-tuneh/DEVICE/Tango2Epics: "sr/d-mtune/utca-horizontal"


# --- sr/d-mtune/utca-horizontal properties

sr/d-mtune/utca-horizontal->Variables: SR-TFIT:X:CENTRE:HEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_HEIGHT,\ 
                                       SR-TFIT:X:CENTRE:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_PHASE,\ 
                                       SR-TFIT:X:CENTRE:POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_POWER,\ 
                                       SR-TFIT:X:CENTRE:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_TUNE,\ 
                                       SR-TFIT:X:CENTRE:VALID*Scalar*Enum*READ_ONLY*ATTRIBUTE*CENTRE_VALID,\ 
                                       SR-TFIT:X:CENTRE:WIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_WIDTH,\ 
                                       SR-TFIT:X:CONFIG:MAXIMUM_FIT_ERROR_S*Scalar*Double*READ_WRITE*ATTRIBUTE*CONFIG_MAXIMUM_FIT_ERROR_S,\ 
                                       SR-TFIT:X:CONFIG:MAX_PEAKS_S*Scalar*Int*READ_WRITE*ATTRIBUTE*CONFIG_MAX_PEAKS_S,\ 
                                       SR-TFIT:X:CONFIG:MINIMUM_HEIGHT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*CONFIG_MINIMUM_HEIGHT_S,\ 
                                       SR-TFIT:X:CONFIG:MINIMUM_SPACING_S*Scalar*Double*READ_WRITE*ATTRIBUTE*CONFIG_MINIMUM_SPACING_S,\ 
                                       SR-TFIT:X:CONFIG:MINIMUM_WIDTH_S*Scalar*Double*READ_WRITE*ATTRIBUTE*CONFIG_MINIMUM_WIDTH_S,\ 
                                       SR-TFIT:X:CONFIG:SMOOTHING_S*Scalar*Int*READ_WRITE*ATTRIBUTE*CONFIG_SMOOTHING_S,\ 
                                       SR-TFIT:X:FIT_ERROR*Scalar*Double*READ_ONLY*ATTRIBUTE*FIT_ERROR,\ 
                                       SR-TFIT:X:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*I,\ 
                                       SR-TFIT:X:LAST_ERROR*Scalar*String*READ_ONLY*ATTRIBUTE*LAST_ERROR,\ 
                                       SR-TFIT:X:LEFT:DPHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_DPHASE,\ 
                                       SR-TFIT:X:LEFT:DTUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_DTUNE,\ 
                                       SR-TFIT:X:LEFT:HEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_HEIGHT,\ 
                                       SR-TFIT:X:LEFT:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_PHASE,\ 
                                       SR-TFIT:X:LEFT:POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_POWER,\ 
                                       SR-TFIT:X:LEFT:RHEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_RHEIGHT,\ 
                                       SR-TFIT:X:LEFT:RPOWER*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_RPOWER,\ 
                                       SR-TFIT:X:LEFT:RWIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_RWIDTH,\ 
                                       SR-TFIT:X:LEFT:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_TUNE,\ 
                                       SR-TFIT:X:LEFT:VALID*Scalar*Enum*READ_ONLY*ATTRIBUTE*LEFT_VALID,\ 
                                       SR-TFIT:X:LEFT:WIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_WIDTH,\ 
                                       SR-TFIT:X:MI*Array:4096*Double*READ_ONLY*ATTRIBUTE*MI,\ 
                                       SR-TFIT:X:MPOWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*MPOWER,\ 
                                       SR-TFIT:X:MQ*Array:4096*Double*READ_ONLY*ATTRIBUTE*MQ,\ 
                                       SR-TFIT:X:PEAK:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*PEAK_PHASE,\ 
                                       SR-TFIT:X:PEAK:SYNCTUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*PEAK_SYNCTUNE,\ 
                                       SR-TFIT:X:PEAK:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*PEAK_TUNE,\ 
                                       SR-TFIT:X:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*PHASE,\ 
                                       SR-TFIT:X:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*POWER,\ 
                                       SR-TFIT:X:PREFIX*Scalar*String*READ_ONLY*ATTRIBUTE*PREFIX,\ 
                                       SR-TFIT:X:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*Q,\ 
                                       SR-TFIT:X:RESIDUE*Array:4096*Double*READ_ONLY*ATTRIBUTE*RESIDUE,\ 
                                       SR-TFIT:X:RIGHT:DPHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_DPHASE,\ 
                                       SR-TFIT:X:RIGHT:DTUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_DTUNE,\ 
                                       SR-TFIT:X:RIGHT:HEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_HEIGHT,\ 
                                       SR-TFIT:X:RIGHT:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_PHASE,\ 
                                       SR-TFIT:X:RIGHT:POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_POWER,\ 
                                       SR-TFIT:X:RIGHT:RHEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_RHEIGHT,\ 
                                       SR-TFIT:X:RIGHT:RPOWER*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_RPOWER,\ 
                                       SR-TFIT:X:RIGHT:RWIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_RWIDTH,\ 
                                       SR-TFIT:X:RIGHT:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_TUNE,\ 
                                       SR-TFIT:X:RIGHT:VALID*Scalar*Enum*READ_ONLY*ATTRIBUTE*RIGHT_VALID,\ 
                                       SR-TFIT:X:RIGHT:WIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_WIDTH,\ 
                                       SR-TFIT:X:SCALE*Array:4096*Double*READ_ONLY*ATTRIBUTE*SCALE,\ 
                                       SR-TFIT:X:SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SELECT_S,\ 
                                       SR-TFIT:X:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*TUNE

# --- sr/d-mtune/utca-horizontal attribute properties

sr/d-mtune/utca-horizontal/CENTRE_HEIGHT->description: "Peak height"
sr/d-mtune/utca-horizontal/CENTRE_HEIGHT->format: %.3f
sr/d-mtune/utca-horizontal/CENTRE_PHASE->description: "Peak phase"
sr/d-mtune/utca-horizontal/CENTRE_PHASE->format: %.1f
sr/d-mtune/utca-horizontal/CENTRE_PHASE->max_value: 180.0
sr/d-mtune/utca-horizontal/CENTRE_PHASE->min_value: -180.0
sr/d-mtune/utca-horizontal/CENTRE_PHASE->unit: deg
sr/d-mtune/utca-horizontal/CENTRE_POWER->description: "Peak power"
sr/d-mtune/utca-horizontal/CENTRE_POWER->format: %.3f
sr/d-mtune/utca-horizontal/CENTRE_TUNE->description: "Peak centre frequency"
sr/d-mtune/utca-horizontal/CENTRE_TUNE->format: %.5f
sr/d-mtune/utca-horizontal/CENTRE_TUNE->max_value: 1.0
sr/d-mtune/utca-horizontal/CENTRE_TUNE->min_value: 0.0
sr/d-mtune/utca-horizontal/CENTRE_VALID->description: "Peak valid"
sr/d-mtune/utca-horizontal/CENTRE_VALID->EnumLabels: Invalid,\ 
                                                     Ok
sr/d-mtune/utca-horizontal/CENTRE_WIDTH->description: "Peak width"
sr/d-mtune/utca-horizontal/CENTRE_WIDTH->format: %.3f
sr/d-mtune/utca-horizontal/CENTRE_WIDTH->max_value: 1.0
sr/d-mtune/utca-horizontal/CENTRE_WIDTH->min_value: 0.0
sr/d-mtune/utca-horizontal/CONFIG_MAXIMUM_FIT_ERROR_S->description: "Reject overall fit if error this large"
sr/d-mtune/utca-horizontal/CONFIG_MAXIMUM_FIT_ERROR_S->format: %.3f
sr/d-mtune/utca-horizontal/CONFIG_MAXIMUM_FIT_ERROR_S->max_value: 1.0
sr/d-mtune/utca-horizontal/CONFIG_MAXIMUM_FIT_ERROR_S->min_value: 0.0
sr/d-mtune/utca-horizontal/CONFIG_MAX_PEAKS_S->description: "Maximum number of peaks to fit"
sr/d-mtune/utca-horizontal/CONFIG_MINIMUM_HEIGHT_S->description: "Reject peaks shorter than this"
sr/d-mtune/utca-horizontal/CONFIG_MINIMUM_HEIGHT_S->format: %.3f
sr/d-mtune/utca-horizontal/CONFIG_MINIMUM_HEIGHT_S->max_value: 1.0
sr/d-mtune/utca-horizontal/CONFIG_MINIMUM_HEIGHT_S->min_value: 0.0
sr/d-mtune/utca-horizontal/CONFIG_MINIMUM_SPACING_S->description: "Reject peaks closer than this"
sr/d-mtune/utca-horizontal/CONFIG_MINIMUM_SPACING_S->format: %.2f
sr/d-mtune/utca-horizontal/CONFIG_MINIMUM_SPACING_S->max_value: 2.0
sr/d-mtune/utca-horizontal/CONFIG_MINIMUM_SPACING_S->min_value: 0.0
sr/d-mtune/utca-horizontal/CONFIG_MINIMUM_WIDTH_S->description: "Reject peaks narrower than this"
sr/d-mtune/utca-horizontal/CONFIG_MINIMUM_WIDTH_S->format: %.2f
sr/d-mtune/utca-horizontal/CONFIG_MINIMUM_WIDTH_S->max_value: 1.0
sr/d-mtune/utca-horizontal/CONFIG_MINIMUM_WIDTH_S->min_value: 0.0
sr/d-mtune/utca-horizontal/CONFIG_SMOOTHING_S->description: "Degree of smoothing for 2D peak detect"
sr/d-mtune/utca-horizontal/FIT_ERROR->format: %.5f
sr/d-mtune/utca-horizontal/LEFT_DPHASE->description: "Delta phase"
sr/d-mtune/utca-horizontal/LEFT_DPHASE->format: %.1f
sr/d-mtune/utca-horizontal/LEFT_DPHASE->max_value: 180.0
sr/d-mtune/utca-horizontal/LEFT_DPHASE->min_value: -180.0
sr/d-mtune/utca-horizontal/LEFT_DPHASE->unit: deg
sr/d-mtune/utca-horizontal/LEFT_DTUNE->description: "Delta tune"
sr/d-mtune/utca-horizontal/LEFT_DTUNE->format: %.5f
sr/d-mtune/utca-horizontal/LEFT_DTUNE->max_value: 1.0
sr/d-mtune/utca-horizontal/LEFT_DTUNE->min_value: 0.0
sr/d-mtune/utca-horizontal/LEFT_HEIGHT->description: "Peak height"
sr/d-mtune/utca-horizontal/LEFT_HEIGHT->format: %.3f
sr/d-mtune/utca-horizontal/LEFT_PHASE->description: "Peak phase"
sr/d-mtune/utca-horizontal/LEFT_PHASE->format: %.1f
sr/d-mtune/utca-horizontal/LEFT_PHASE->max_value: 180.0
sr/d-mtune/utca-horizontal/LEFT_PHASE->min_value: -180.0
sr/d-mtune/utca-horizontal/LEFT_PHASE->unit: deg
sr/d-mtune/utca-horizontal/LEFT_POWER->description: "Peak power"
sr/d-mtune/utca-horizontal/LEFT_POWER->format: %.3f
sr/d-mtune/utca-horizontal/LEFT_RHEIGHT->description: "Relative height"
sr/d-mtune/utca-horizontal/LEFT_RHEIGHT->format: %.3f
sr/d-mtune/utca-horizontal/LEFT_RPOWER->description: "Relative power"
sr/d-mtune/utca-horizontal/LEFT_RPOWER->format: %.3f
sr/d-mtune/utca-horizontal/LEFT_RWIDTH->description: "Relative width"
sr/d-mtune/utca-horizontal/LEFT_RWIDTH->format: %.3f
sr/d-mtune/utca-horizontal/LEFT_RWIDTH->max_value: 1.0
sr/d-mtune/utca-horizontal/LEFT_RWIDTH->min_value: 0.0
sr/d-mtune/utca-horizontal/LEFT_TUNE->description: "Peak centre frequency"
sr/d-mtune/utca-horizontal/LEFT_TUNE->format: %.5f
sr/d-mtune/utca-horizontal/LEFT_TUNE->max_value: 1.0
sr/d-mtune/utca-horizontal/LEFT_TUNE->min_value: 0.0
sr/d-mtune/utca-horizontal/LEFT_VALID->description: "Peak valid"
sr/d-mtune/utca-horizontal/LEFT_VALID->EnumLabels: Invalid,\ 
                                                   Ok
sr/d-mtune/utca-horizontal/LEFT_WIDTH->description: "Peak width"
sr/d-mtune/utca-horizontal/LEFT_WIDTH->format: %.3f
sr/d-mtune/utca-horizontal/LEFT_WIDTH->max_value: 1.0
sr/d-mtune/utca-horizontal/LEFT_WIDTH->min_value: 0.0
sr/d-mtune/utca-horizontal/PEAK_PHASE->description: "Measured tune phase"
sr/d-mtune/utca-horizontal/PEAK_PHASE->format: %.1f
sr/d-mtune/utca-horizontal/PEAK_PHASE->max_value: 180.0
sr/d-mtune/utca-horizontal/PEAK_PHASE->min_value: -180.0
sr/d-mtune/utca-horizontal/PEAK_PHASE->unit: deg
sr/d-mtune/utca-horizontal/PEAK_SYNCTUNE->description: "Synchrotron tune"
sr/d-mtune/utca-horizontal/PEAK_SYNCTUNE->format: %.5f
sr/d-mtune/utca-horizontal/PEAK_SYNCTUNE->max_value: 1.0
sr/d-mtune/utca-horizontal/PEAK_SYNCTUNE->min_value: 0.0
sr/d-mtune/utca-horizontal/PEAK_TUNE->description: "Measured tune"
sr/d-mtune/utca-horizontal/PEAK_TUNE->format: %.5f
sr/d-mtune/utca-horizontal/PEAK_TUNE->max_value: 1.0
sr/d-mtune/utca-horizontal/PEAK_TUNE->min_value: 0.0
sr/d-mtune/utca-horizontal/PHASE->description: "Selected tune phase"
sr/d-mtune/utca-horizontal/PHASE->format: %.1f
sr/d-mtune/utca-horizontal/PHASE->max_value: 180.0
sr/d-mtune/utca-horizontal/PHASE->min_value: -180.0
sr/d-mtune/utca-horizontal/PHASE->unit: deg
sr/d-mtune/utca-horizontal/RIGHT_DPHASE->description: "Delta phase"
sr/d-mtune/utca-horizontal/RIGHT_DPHASE->format: %.1f
sr/d-mtune/utca-horizontal/RIGHT_DPHASE->max_value: 180.0
sr/d-mtune/utca-horizontal/RIGHT_DPHASE->min_value: -180.0
sr/d-mtune/utca-horizontal/RIGHT_DPHASE->unit: deg
sr/d-mtune/utca-horizontal/RIGHT_DTUNE->description: "Delta tune"
sr/d-mtune/utca-horizontal/RIGHT_DTUNE->format: %.5f
sr/d-mtune/utca-horizontal/RIGHT_DTUNE->max_value: 1.0
sr/d-mtune/utca-horizontal/RIGHT_DTUNE->min_value: 0.0
sr/d-mtune/utca-horizontal/RIGHT_HEIGHT->description: "Peak height"
sr/d-mtune/utca-horizontal/RIGHT_HEIGHT->format: %.3f
sr/d-mtune/utca-horizontal/RIGHT_PHASE->description: "Peak phase"
sr/d-mtune/utca-horizontal/RIGHT_PHASE->format: %.1f
sr/d-mtune/utca-horizontal/RIGHT_PHASE->max_value: 180.0
sr/d-mtune/utca-horizontal/RIGHT_PHASE->min_value: -180.0
sr/d-mtune/utca-horizontal/RIGHT_PHASE->unit: deg
sr/d-mtune/utca-horizontal/RIGHT_POWER->description: "Peak power"
sr/d-mtune/utca-horizontal/RIGHT_POWER->format: %.3f
sr/d-mtune/utca-horizontal/RIGHT_RHEIGHT->description: "Relative height"
sr/d-mtune/utca-horizontal/RIGHT_RHEIGHT->format: %.3f
sr/d-mtune/utca-horizontal/RIGHT_RPOWER->description: "Relative power"
sr/d-mtune/utca-horizontal/RIGHT_RPOWER->format: %.3f
sr/d-mtune/utca-horizontal/RIGHT_RWIDTH->description: "Relative width"
sr/d-mtune/utca-horizontal/RIGHT_RWIDTH->format: %.3f
sr/d-mtune/utca-horizontal/RIGHT_RWIDTH->max_value: 1.0
sr/d-mtune/utca-horizontal/RIGHT_RWIDTH->min_value: 0.0
sr/d-mtune/utca-horizontal/RIGHT_TUNE->description: "Peak centre frequency"
sr/d-mtune/utca-horizontal/RIGHT_TUNE->format: %.5f
sr/d-mtune/utca-horizontal/RIGHT_TUNE->max_value: 1.0
sr/d-mtune/utca-horizontal/RIGHT_TUNE->min_value: 0.0
sr/d-mtune/utca-horizontal/RIGHT_VALID->description: "Peak valid"
sr/d-mtune/utca-horizontal/RIGHT_VALID->EnumLabels: Invalid,\ 
                                                    Ok
sr/d-mtune/utca-horizontal/RIGHT_WIDTH->description: "Peak width"
sr/d-mtune/utca-horizontal/RIGHT_WIDTH->format: %.3f
sr/d-mtune/utca-horizontal/RIGHT_WIDTH->max_value: 1.0
sr/d-mtune/utca-horizontal/RIGHT_WIDTH->min_value: 0.0
sr/d-mtune/utca-horizontal/SELECT_S->description: "Select which tune to use"
sr/d-mtune/utca-horizontal/SELECT_S->EnumLabels: "Peak Fit",\ 
                                                 Machine
sr/d-mtune/utca-horizontal/TUNE->description: "Selected tune"
sr/d-mtune/utca-horizontal/TUNE->format: %.5f
sr/d-mtune/utca-horizontal/TUNE->max_value: 1.0
sr/d-mtune/utca-horizontal/TUNE->min_value: 0.0

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


