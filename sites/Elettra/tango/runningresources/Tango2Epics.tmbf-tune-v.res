#
# Resource backup , created Tue Feb 11 12:10:55 CET 2020
#

#---------------------------------------------------------
# SERVER Tango2Epics/tmbf-tune-v, Tango2Epics device declaration
#---------------------------------------------------------

Tango2Epics/tmbf-tune-v/DEVICE/Tango2Epics: "tmbf/tune_fit/v"


# --- tmbf/tune_fit/v properties

tmbf/tune_fit/v->ArrayAccessTimeout: 0.3
tmbf/tune_fit/v->HelperApplication: "atkpanel tmbf/tune_fit/v"
tmbf/tune_fit/v->polled_attr: tune,\ 
                              1000
tmbf/tune_fit/v->ScalarAccessTimeout: 0.2
tmbf/tune_fit/v->SubscriptionCycle: 0.4
tmbf/tune_fit/v->Variables: SR-TMBF:Y:TUNE:CENTRE:HEIGHT*Scalar*Double*READ_ONLY*ATTRIBUTE*CENTRE_HEIGHT,\ 
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

# --- tmbf/tune_fit/v attribute properties

tmbf/tune_fit/v/CENTRE_HEIGHT->description: "Peak height"
tmbf/tune_fit/v/CENTRE_PHASE->description: "Peak phase"
tmbf/tune_fit/v/CENTRE_PHASE->unit: deg
tmbf/tune_fit/v/CENTRE_POWER->description: "Peak power"
tmbf/tune_fit/v/CENTRE_TUNE->description: "Peak centre frequency"
tmbf/tune_fit/v/CENTRE_VALID->description: "Peak valid"
tmbf/tune_fit/v/CENTRE_VALID->EnumLabels: Invalid,\ 
                                          Ok
tmbf/tune_fit/v/CENTRE_WIDTH->description: "Peak width"
tmbf/tune_fit/v/CONFIG_MAXIMUM_FIT_ERROR_S->description: "Reject overall fit if error this large"
tmbf/tune_fit/v/CONFIG_MAXIMUM_FIT_ERROR_S->format: %.3f
tmbf/tune_fit/v/CONFIG_MAX_PEAKS_S->description: "Maximum number of peaks to fit"
tmbf/tune_fit/v/CONFIG_MAX_PEAKS_S->format: %1d
tmbf/tune_fit/v/CONFIG_MAX_PEAKS_S->max_value: 5.0
tmbf/tune_fit/v/CONFIG_MAX_PEAKS_S->min_value: 1.0
tmbf/tune_fit/v/CONFIG_MINIMUM_HEIGHT_S->description: "Reject peaks shorter than this"
tmbf/tune_fit/v/CONFIG_MINIMUM_HEIGHT_S->format: %.3f
tmbf/tune_fit/v/CONFIG_MINIMUM_SPACING_S->description: "Reject peaks closer than this"
tmbf/tune_fit/v/CONFIG_MINIMUM_SPACING_S->format: %.4f
tmbf/tune_fit/v/CONFIG_MINIMUM_WIDTH_S->description: "Reject peaks narrower than this"
tmbf/tune_fit/v/CONFIG_MINIMUM_WIDTH_S->format: %.2f
tmbf/tune_fit/v/CONFIG_SMOOTHING_S->description: "Degree of smoothing for 2D peak detect"
tmbf/tune_fit/v/CONFIG_SMOOTHING_S->format: %2d
tmbf/tune_fit/v/CONFIG_SMOOTHING_S->max_value: 64.0
tmbf/tune_fit/v/CONFIG_SMOOTHING_S->min_value: 8.0
tmbf/tune_fit/v/LEFT_DPHASE->description: "Delta phase"
tmbf/tune_fit/v/LEFT_DPHASE->unit: deg
tmbf/tune_fit/v/LEFT_DTUNE->description: "Delta tune"
tmbf/tune_fit/v/LEFT_HEIGHT->description: "Peak height"
tmbf/tune_fit/v/LEFT_PHASE->description: "Peak phase"
tmbf/tune_fit/v/LEFT_PHASE->unit: deg
tmbf/tune_fit/v/LEFT_POWER->description: "Peak power"
tmbf/tune_fit/v/LEFT_RHEIGHT->description: "Relative height"
tmbf/tune_fit/v/LEFT_RPOWER->description: "Relative power"
tmbf/tune_fit/v/LEFT_RWIDTH->description: "Relative width"
tmbf/tune_fit/v/LEFT_TUNE->description: "Peak centre frequency"
tmbf/tune_fit/v/LEFT_VALID->description: "Peak valid"
tmbf/tune_fit/v/LEFT_VALID->EnumLabels: Invalid,\ 
                                        Ok
tmbf/tune_fit/v/LEFT_WIDTH->description: "Peak width"
tmbf/tune_fit/v/PHASE->description: "Measured tune phase"
tmbf/tune_fit/v/PHASE->unit: deg
tmbf/tune_fit/v/RIGHT_DPHASE->description: "Delta phase"
tmbf/tune_fit/v/RIGHT_DPHASE->unit: deg
tmbf/tune_fit/v/RIGHT_DTUNE->description: "Delta tune"
tmbf/tune_fit/v/RIGHT_HEIGHT->description: "Peak height"
tmbf/tune_fit/v/RIGHT_PHASE->description: "Peak phase"
tmbf/tune_fit/v/RIGHT_PHASE->unit: deg
tmbf/tune_fit/v/RIGHT_POWER->description: "Peak power"
tmbf/tune_fit/v/RIGHT_RHEIGHT->description: "Relative height"
tmbf/tune_fit/v/RIGHT_RPOWER->description: "Relative power"
tmbf/tune_fit/v/RIGHT_RWIDTH->description: "Relative width"
tmbf/tune_fit/v/RIGHT_TUNE->description: "Peak centre frequency"
tmbf/tune_fit/v/RIGHT_VALID->description: "Peak valid"
tmbf/tune_fit/v/RIGHT_VALID->EnumLabels: Invalid,\ 
                                         Ok
tmbf/tune_fit/v/RIGHT_WIDTH->description: "Peak width"
tmbf/tune_fit/v/SYNCTUNE->description: "Synchrotron tune"
tmbf/tune_fit/v/TUNE->archive_abs_change: -0.0002,\ 
                                          0.0002
tmbf/tune_fit/v/TUNE->archive_period: 180000
tmbf/tune_fit/v/TUNE->description: "Measured tune"

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



# --- dserver/Tango2Epics/tmbf-tune-v properties

dserver/Tango2Epics/tmbf-tune-v->polling_threads_pool_conf: "tmbf/tune_fit/v"
