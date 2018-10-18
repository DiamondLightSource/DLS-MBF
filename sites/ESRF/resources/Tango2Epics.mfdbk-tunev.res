#
# Resource backup , created Thu Jun 28 12:48:03 CEST 2018
#

#---------------------------------------------------------
# SERVER Tango2Epics/mfdbk-tunev, Tango2Epics device declaration
#---------------------------------------------------------

Tango2Epics/mfdbk-tunev/DEVICE/Tango2Epics: "sr/d-mtune/utca-vertical"


# --- sr/d-mtune/utca-vertical properties

sr/d-mtune/utca-vertical->Variables: SR-TFIT:Y:CENTRE:HEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_HEIGHT,\ 
                                     SR-TFIT:Y:CENTRE:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_PHASE,\ 
                                     SR-TFIT:Y:CENTRE:POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_POWER,\ 
                                     SR-TFIT:Y:CENTRE:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_TUNE,\ 
                                     SR-TFIT:Y:CENTRE:VALID*Scalar*Enum*READ_ONLY*ATTRIBUTE*CENTRE_VALID,\ 
                                     SR-TFIT:Y:CENTRE:WIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_WIDTH,\ 
                                     SR-TFIT:Y:CONFIG:MAXIMUM_FIT_ERROR_S*Scalar*Double*READ_WRITE*ATTRIBUTE*CONFIG_MAXIMUM_FIT_ERROR_S,\ 
                                     SR-TFIT:Y:CONFIG:MAX_PEAKS_S*Scalar*Int*READ_WRITE*ATTRIBUTE*CONFIG_MAX_PEAKS_S,\ 
                                     SR-TFIT:Y:CONFIG:MINIMUM_HEIGHT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*CONFIG_MINIMUM_HEIGHT_S,\ 
                                     SR-TFIT:Y:CONFIG:MINIMUM_SPACING_S*Scalar*Double*READ_WRITE*ATTRIBUTE*CONFIG_MINIMUM_SPACING_S,\ 
                                     SR-TFIT:Y:CONFIG:MINIMUM_WIDTH_S*Scalar*Double*READ_WRITE*ATTRIBUTE*CONFIG_MINIMUM_WIDTH_S,\ 
                                     SR-TFIT:Y:CONFIG:SMOOTHING_S*Scalar*Int*READ_WRITE*ATTRIBUTE*CONFIG_SMOOTHING_S,\ 
                                     SR-TFIT:Y:FIT_ERROR*Scalar*Double*READ_ONLY*ATTRIBUTE*FIT_ERROR,\ 
                                     SR-TFIT:Y:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*I,\ 
                                     SR-TFIT:Y:LAST_ERROR*Scalar*String*READ_ONLY*ATTRIBUTE*LAST_ERROR,\ 
                                     SR-TFIT:Y:LEFT:DPHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_DPHASE,\ 
                                     SR-TFIT:Y:LEFT:DTUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_DTUNE,\ 
                                     SR-TFIT:Y:LEFT:HEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_HEIGHT,\ 
                                     SR-TFIT:Y:LEFT:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_PHASE,\ 
                                     SR-TFIT:Y:LEFT:POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_POWER,\ 
                                     SR-TFIT:Y:LEFT:RHEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_RHEIGHT,\ 
                                     SR-TFIT:Y:LEFT:RPOWER*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_RPOWER,\ 
                                     SR-TFIT:Y:LEFT:RWIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_RWIDTH,\ 
                                     SR-TFIT:Y:LEFT:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_TUNE,\ 
                                     SR-TFIT:Y:LEFT:VALID*Scalar*Enum*READ_ONLY*ATTRIBUTE*LEFT_VALID,\ 
                                     SR-TFIT:Y:LEFT:WIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*LEFT_WIDTH,\ 
                                     SR-TFIT:Y:MI*Array:4096*Double*READ_ONLY*ATTRIBUTE*MI,\ 
                                     SR-TFIT:Y:MPOWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*MPOWER,\ 
                                     SR-TFIT:Y:MQ*Array:4096*Double*READ_ONLY*ATTRIBUTE*MQ,\ 
                                     SR-TFIT:Y:PEAK:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*PEAK_PHASE,\ 
                                     SR-TFIT:Y:PEAK:SYNCTUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*PEAK_SYNCTUNE,\ 
                                     SR-TFIT:Y:PEAK:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*PEAK_TUNE,\ 
                                     SR-TFIT:Y:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*PHASE,\ 
                                     SR-TFIT:Y:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*POWER,\ 
                                     SR-TFIT:Y:PREFIX*Scalar*String*READ_ONLY*ATTRIBUTE*PREFIX,\ 
                                     SR-TFIT:Y:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*Q,\ 
                                     SR-TFIT:Y:RESIDUE*Array:4096*Double*READ_ONLY*ATTRIBUTE*RESIDUE,\ 
                                     SR-TFIT:Y:RIGHT:DPHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_DPHASE,\ 
                                     SR-TFIT:Y:RIGHT:DTUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_DTUNE,\ 
                                     SR-TFIT:Y:RIGHT:HEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_HEIGHT,\ 
                                     SR-TFIT:Y:RIGHT:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_PHASE,\ 
                                     SR-TFIT:Y:RIGHT:POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_POWER,\ 
                                     SR-TFIT:Y:RIGHT:RHEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_RHEIGHT,\ 
                                     SR-TFIT:Y:RIGHT:RPOWER*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_RPOWER,\ 
                                     SR-TFIT:Y:RIGHT:RWIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_RWIDTH,\ 
                                     SR-TFIT:Y:RIGHT:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_TUNE,\ 
                                     SR-TFIT:Y:RIGHT:VALID*Scalar*Enum*READ_ONLY*ATTRIBUTE*RIGHT_VALID,\ 
                                     SR-TFIT:Y:RIGHT:WIDTH*Scalar*Double*READ_ONLY*ATTRIBUTE*RIGHT_WIDTH,\ 
                                     SR-TFIT:Y:SCALE*Array:4096*Double*READ_ONLY*ATTRIBUTE*SCALE,\ 
                                     SR-TFIT:Y:SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SELECT_S,\ 
                                     SR-TFIT:Y:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*TUNE

# --- sr/d-mtune/utca-vertical attribute properties

sr/d-mtune/utca-vertical/CENTRE_HEIGHT->description: "Peak height"
sr/d-mtune/utca-vertical/CENTRE_HEIGHT->format: %.3f
sr/d-mtune/utca-vertical/CENTRE_PHASE->description: "Peak phase"
sr/d-mtune/utca-vertical/CENTRE_PHASE->format: %.1f
sr/d-mtune/utca-vertical/CENTRE_PHASE->max_value: 180.0
sr/d-mtune/utca-vertical/CENTRE_PHASE->min_value: -180.0
sr/d-mtune/utca-vertical/CENTRE_PHASE->unit: deg
sr/d-mtune/utca-vertical/CENTRE_POWER->description: "Peak power"
sr/d-mtune/utca-vertical/CENTRE_POWER->format: %.3f
sr/d-mtune/utca-vertical/CENTRE_TUNE->description: "Peak centre frequency"
sr/d-mtune/utca-vertical/CENTRE_TUNE->format: %.5f
sr/d-mtune/utca-vertical/CENTRE_TUNE->max_value: 1.0
sr/d-mtune/utca-vertical/CENTRE_TUNE->min_value: 0.0
sr/d-mtune/utca-vertical/CENTRE_VALID->description: "Peak valid"
sr/d-mtune/utca-vertical/CENTRE_VALID->EnumLabels: Invalid,\ 
                                                   Ok
sr/d-mtune/utca-vertical/CENTRE_WIDTH->description: "Peak width"
sr/d-mtune/utca-vertical/CENTRE_WIDTH->format: %.3f
sr/d-mtune/utca-vertical/CENTRE_WIDTH->max_value: 1.0
sr/d-mtune/utca-vertical/CENTRE_WIDTH->min_value: 0.0
sr/d-mtune/utca-vertical/CONFIG_MAXIMUM_FIT_ERROR_S->description: "Reject overall fit if error this large"
sr/d-mtune/utca-vertical/CONFIG_MAXIMUM_FIT_ERROR_S->format: %.3f
sr/d-mtune/utca-vertical/CONFIG_MAXIMUM_FIT_ERROR_S->max_value: 1.0
sr/d-mtune/utca-vertical/CONFIG_MAXIMUM_FIT_ERROR_S->min_value: 0.0
sr/d-mtune/utca-vertical/CONFIG_MAX_PEAKS_S->description: "Maximum number of peaks to fit"
sr/d-mtune/utca-vertical/CONFIG_MINIMUM_HEIGHT_S->description: "Reject peaks shorter than this"
sr/d-mtune/utca-vertical/CONFIG_MINIMUM_HEIGHT_S->format: %.3f
sr/d-mtune/utca-vertical/CONFIG_MINIMUM_HEIGHT_S->max_value: 1.0
sr/d-mtune/utca-vertical/CONFIG_MINIMUM_HEIGHT_S->min_value: 0.0
sr/d-mtune/utca-vertical/CONFIG_MINIMUM_SPACING_S->description: "Reject peaks closer than this"
sr/d-mtune/utca-vertical/CONFIG_MINIMUM_SPACING_S->format: %.2f
sr/d-mtune/utca-vertical/CONFIG_MINIMUM_SPACING_S->max_value: 2.0
sr/d-mtune/utca-vertical/CONFIG_MINIMUM_SPACING_S->min_value: 0.0
sr/d-mtune/utca-vertical/CONFIG_MINIMUM_WIDTH_S->description: "Reject peaks narrower than this"
sr/d-mtune/utca-vertical/CONFIG_MINIMUM_WIDTH_S->format: %.2f
sr/d-mtune/utca-vertical/CONFIG_MINIMUM_WIDTH_S->max_value: 1.0
sr/d-mtune/utca-vertical/CONFIG_MINIMUM_WIDTH_S->min_value: 0.0
sr/d-mtune/utca-vertical/CONFIG_SMOOTHING_S->description: "Degree of smoothing for 2D peak detect"
sr/d-mtune/utca-vertical/FIT_ERROR->format: %.5f
sr/d-mtune/utca-vertical/LEFT_DPHASE->description: "Delta phase"
sr/d-mtune/utca-vertical/LEFT_DPHASE->format: %.1f
sr/d-mtune/utca-vertical/LEFT_DPHASE->max_value: 180.0
sr/d-mtune/utca-vertical/LEFT_DPHASE->min_value: -180.0
sr/d-mtune/utca-vertical/LEFT_DPHASE->unit: deg
sr/d-mtune/utca-vertical/LEFT_DTUNE->description: "Delta tune"
sr/d-mtune/utca-vertical/LEFT_DTUNE->format: %.5f
sr/d-mtune/utca-vertical/LEFT_DTUNE->max_value: 1.0
sr/d-mtune/utca-vertical/LEFT_DTUNE->min_value: 0.0
sr/d-mtune/utca-vertical/LEFT_HEIGHT->description: "Peak height"
sr/d-mtune/utca-vertical/LEFT_HEIGHT->format: %.3f
sr/d-mtune/utca-vertical/LEFT_PHASE->description: "Peak phase"
sr/d-mtune/utca-vertical/LEFT_PHASE->format: %.1f
sr/d-mtune/utca-vertical/LEFT_PHASE->max_value: 180.0
sr/d-mtune/utca-vertical/LEFT_PHASE->min_value: -180.0
sr/d-mtune/utca-vertical/LEFT_PHASE->unit: deg
sr/d-mtune/utca-vertical/LEFT_POWER->description: "Peak power"
sr/d-mtune/utca-vertical/LEFT_POWER->format: %.3f
sr/d-mtune/utca-vertical/LEFT_RHEIGHT->description: "Relative height"
sr/d-mtune/utca-vertical/LEFT_RHEIGHT->format: %.3f
sr/d-mtune/utca-vertical/LEFT_RPOWER->description: "Relative power"
sr/d-mtune/utca-vertical/LEFT_RPOWER->format: %.3f
sr/d-mtune/utca-vertical/LEFT_RWIDTH->description: "Relative width"
sr/d-mtune/utca-vertical/LEFT_RWIDTH->format: %.3f
sr/d-mtune/utca-vertical/LEFT_RWIDTH->max_value: 1.0
sr/d-mtune/utca-vertical/LEFT_RWIDTH->min_value: 0.0
sr/d-mtune/utca-vertical/LEFT_TUNE->description: "Peak centre frequency"
sr/d-mtune/utca-vertical/LEFT_TUNE->format: %.5f
sr/d-mtune/utca-vertical/LEFT_TUNE->max_value: 1.0
sr/d-mtune/utca-vertical/LEFT_TUNE->min_value: 0.0
sr/d-mtune/utca-vertical/LEFT_VALID->description: "Peak valid"
sr/d-mtune/utca-vertical/LEFT_VALID->EnumLabels: Invalid,\ 
                                                 Ok
sr/d-mtune/utca-vertical/LEFT_WIDTH->description: "Peak width"
sr/d-mtune/utca-vertical/LEFT_WIDTH->format: %.3f
sr/d-mtune/utca-vertical/LEFT_WIDTH->max_value: 1.0
sr/d-mtune/utca-vertical/LEFT_WIDTH->min_value: 0.0
sr/d-mtune/utca-vertical/PEAK_PHASE->description: "Measured tune phase"
sr/d-mtune/utca-vertical/PEAK_PHASE->format: %.1f
sr/d-mtune/utca-vertical/PEAK_PHASE->max_value: 180.0
sr/d-mtune/utca-vertical/PEAK_PHASE->min_value: -180.0
sr/d-mtune/utca-vertical/PEAK_PHASE->unit: deg
sr/d-mtune/utca-vertical/PEAK_SYNCTUNE->description: "Synchrotron tune"
sr/d-mtune/utca-vertical/PEAK_SYNCTUNE->format: %.5f
sr/d-mtune/utca-vertical/PEAK_SYNCTUNE->max_value: 1.0
sr/d-mtune/utca-vertical/PEAK_SYNCTUNE->min_value: 0.0
sr/d-mtune/utca-vertical/PEAK_TUNE->description: "Measured tune"
sr/d-mtune/utca-vertical/PEAK_TUNE->format: %.5f
sr/d-mtune/utca-vertical/PEAK_TUNE->max_value: 1.0
sr/d-mtune/utca-vertical/PEAK_TUNE->min_value: 0.0
sr/d-mtune/utca-vertical/PHASE->description: "Selected tune phase"
sr/d-mtune/utca-vertical/PHASE->format: %.1f
sr/d-mtune/utca-vertical/PHASE->max_value: 180.0
sr/d-mtune/utca-vertical/PHASE->min_value: -180.0
sr/d-mtune/utca-vertical/PHASE->unit: deg
sr/d-mtune/utca-vertical/RIGHT_DPHASE->description: "Delta phase"
sr/d-mtune/utca-vertical/RIGHT_DPHASE->format: %.1f
sr/d-mtune/utca-vertical/RIGHT_DPHASE->max_value: 180.0
sr/d-mtune/utca-vertical/RIGHT_DPHASE->min_value: -180.0
sr/d-mtune/utca-vertical/RIGHT_DPHASE->unit: deg
sr/d-mtune/utca-vertical/RIGHT_DTUNE->description: "Delta tune"
sr/d-mtune/utca-vertical/RIGHT_DTUNE->format: %.5f
sr/d-mtune/utca-vertical/RIGHT_DTUNE->max_value: 1.0
sr/d-mtune/utca-vertical/RIGHT_DTUNE->min_value: 0.0
sr/d-mtune/utca-vertical/RIGHT_HEIGHT->description: "Peak height"
sr/d-mtune/utca-vertical/RIGHT_HEIGHT->format: %.3f
sr/d-mtune/utca-vertical/RIGHT_PHASE->description: "Peak phase"
sr/d-mtune/utca-vertical/RIGHT_PHASE->format: %.1f
sr/d-mtune/utca-vertical/RIGHT_PHASE->max_value: 180.0
sr/d-mtune/utca-vertical/RIGHT_PHASE->min_value: -180.0
sr/d-mtune/utca-vertical/RIGHT_PHASE->unit: deg
sr/d-mtune/utca-vertical/RIGHT_POWER->description: "Peak power"
sr/d-mtune/utca-vertical/RIGHT_POWER->format: %.3f
sr/d-mtune/utca-vertical/RIGHT_RHEIGHT->description: "Relative height"
sr/d-mtune/utca-vertical/RIGHT_RHEIGHT->format: %.3f
sr/d-mtune/utca-vertical/RIGHT_RPOWER->description: "Relative power"
sr/d-mtune/utca-vertical/RIGHT_RPOWER->format: %.3f
sr/d-mtune/utca-vertical/RIGHT_RWIDTH->description: "Relative width"
sr/d-mtune/utca-vertical/RIGHT_RWIDTH->format: %.3f
sr/d-mtune/utca-vertical/RIGHT_RWIDTH->max_value: 1.0
sr/d-mtune/utca-vertical/RIGHT_RWIDTH->min_value: 0.0
sr/d-mtune/utca-vertical/RIGHT_TUNE->description: "Peak centre frequency"
sr/d-mtune/utca-vertical/RIGHT_TUNE->format: %.5f
sr/d-mtune/utca-vertical/RIGHT_TUNE->max_value: 1.0
sr/d-mtune/utca-vertical/RIGHT_TUNE->min_value: 0.0
sr/d-mtune/utca-vertical/RIGHT_VALID->description: "Peak valid"
sr/d-mtune/utca-vertical/RIGHT_VALID->EnumLabels: Invalid,\ 
                                                  Ok
sr/d-mtune/utca-vertical/RIGHT_WIDTH->description: "Peak width"
sr/d-mtune/utca-vertical/RIGHT_WIDTH->format: %.3f
sr/d-mtune/utca-vertical/RIGHT_WIDTH->max_value: 1.0
sr/d-mtune/utca-vertical/RIGHT_WIDTH->min_value: 0.0
sr/d-mtune/utca-vertical/SELECT_S->description: "Select which tune to use"
sr/d-mtune/utca-vertical/SELECT_S->EnumLabels: "Peak Fit",\ 
                                               Machine
sr/d-mtune/utca-vertical/TUNE->description: "Selected tune"
sr/d-mtune/utca-vertical/TUNE->format: %.5f
sr/d-mtune/utca-vertical/TUNE->max_value: 1.0
sr/d-mtune/utca-vertical/TUNE->min_value: 0.0

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


