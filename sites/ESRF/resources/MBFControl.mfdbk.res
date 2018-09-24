#
# Resource backup , created Thu Jun 28 12:48:56 CEST 2018
#

#---------------------------------------------------------
# SERVER MBFControl/mfdbk, MBFControl device declaration
#---------------------------------------------------------

MBFControl/mfdbk/DEVICE/MBFControl: "sr/d-mfdbk/_horizontal",\ 
                                    "sr/d-mfdbk/_vertical"


# --- sr/d-mfdbk/_horizontal properties

sr/d-mfdbk/_horizontal->ConfigFilePath: "/operation/dserver/settings/mfdbk/horizontal"
sr/d-mfdbk/_horizontal->DoorDevice: "sr/d-mfdbk/door-horizontal"
sr/d-mfdbk/_horizontal->GMBFDevice: "sr/d-mfdbk/utca-global"
sr/d-mfdbk/_horizontal->MacroServerDevice: "sr/d-mfdbk/macro"
sr/d-mfdbk/_horizontal->MBFDevice: "sr/d-mfdbk/utca-horizontal"
sr/d-mfdbk/_horizontal->ModeList: "7/8+1",\ 
                                  16-bunch,\ 
                                  4-bunch,\ 
                                  Hybrid,\ 
                                  Uniform
sr/d-mfdbk/_horizontal->polled_attr: state,\ 
                                     1000
sr/d-mfdbk/_horizontal->__SubDevices: "sr/d-mfdbk/utca-horizontal",\ 
                                      "sr/d-mfdbk/door-horizontal",\ 
                                      "sr/d-mfdbk/utca-global"

# --- sr/d-mfdbk/_horizontal attribute properties

sr/d-mfdbk/_horizontal/BlankingInterval->__value: 10000
sr/d-mfdbk/_horizontal/CleaningFineGain->__value: 1
sr/d-mfdbk/_horizontal/FeedbackFineGain->__value: 1
sr/d-mfdbk/_horizontal/FeedbackGain->EnumLabels: 48dB,\ 
                                                 42dB,\ 
                                                 36dB,\ 
                                                 30dB,\ 
                                                 24dB,\ 
                                                 18dB,\ 
                                                 12dB,\ 
                                                 6dB,\ 
                                                 0dB,\ 
                                                 -6dB,\ 
                                                 -12dB,\ 
                                                 -18dB,\ 
                                                 -24dB,\ 
                                                 -30dB,\ 
                                                 -36dB,\ 
                                                 -42dB
sr/d-mfdbk/_horizontal/FeedbackGain->__value: 7
sr/d-mfdbk/_horizontal/FeedbackPhase->__value: 24
sr/d-mfdbk/_horizontal/Harmonic->__value: 77
sr/d-mfdbk/_horizontal/Mode->enum_labels: "7/8+1",\ 
                                          16-bunch,\ 
                                          4-bunch,\ 
                                          Hybrid,\ 
                                          Uniform
sr/d-mfdbk/_horizontal/Mode->__value: 0
sr/d-mfdbk/_horizontal/SweepDwellTime->__value: 100
sr/d-mfdbk/_horizontal/SweepGain->EnumLabels: 0dB,\ 
                                              -6dB,\ 
                                              -12dB,\ 
                                              -18dB,\ 
                                              -24dB,\ 
                                              -30dB,\ 
                                              -36dB,\ 
                                              -42dB,\ 
                                              -48dB,\ 
                                              -54dB,\ 
                                              -60dB,\ 
                                              -66dB,\ 
                                              -72dB,\ 
                                              -78dB,\ 
                                              -84dB,\ 
                                              -90dB
sr/d-mfdbk/_horizontal/SweepGain->__value: 5
sr/d-mfdbk/_horizontal/SweepRange->__value: 0.05
sr/d-mfdbk/_horizontal/Tune->__value: 0.44
sr/d-mfdbk/_horizontal/TuneBunch->__value: 450
sr/d-mfdbk/_horizontal/TuneOnSingleBunch->__value: false

# --- sr/d-mfdbk/_vertical properties

sr/d-mfdbk/_vertical->ConfigFilePath: "/operation/dserver/settings/mfdbk/vertical"
sr/d-mfdbk/_vertical->DoorDevice: "sr/d-mfdbk/door-vertical"
sr/d-mfdbk/_vertical->GMBFDevice: "sr/d-mfdbk/utca-global"
sr/d-mfdbk/_vertical->MacroServerDevice: "sr/d-mfdbk/macro"
sr/d-mfdbk/_vertical->MBFDevice: "sr/d-mfdbk/utca-vertical"
sr/d-mfdbk/_vertical->ModeList: "7/8+1",\ 
                                16-bunch,\ 
                                4-bunch,\ 
                                Hybrid,\ 
                                Uniform
sr/d-mfdbk/_vertical->polled_attr: state,\ 
                                   1000
sr/d-mfdbk/_vertical->__SubDevices: "sr/d-mfdbk/utca-vertical",\ 
                                    "sr/d-mfdbk/door-vertical",\ 
                                    "sr/d-mfdbk/utca-global"

# --- sr/d-mfdbk/_vertical attribute properties

sr/d-mfdbk/_vertical/BlankingInterval->__value: 10000
sr/d-mfdbk/_vertical/CleaningFineGain->__value: 1
sr/d-mfdbk/_vertical/FeedbackFineGain->__value: 1
sr/d-mfdbk/_vertical/FeedbackGain->EnumLabels: 48dB,\ 
                                               42dB,\ 
                                               36dB,\ 
                                               30dB,\ 
                                               24dB,\ 
                                               18dB,\ 
                                               12dB,\ 
                                               6dB,\ 
                                               0dB,\ 
                                               -6dB,\ 
                                               -12dB,\ 
                                               -18dB,\ 
                                               -24dB,\ 
                                               -30dB,\ 
                                               -36dB,\ 
                                               -42dB
sr/d-mfdbk/_vertical/FeedbackGain->__value: 8
sr/d-mfdbk/_vertical/FeedbackPhase->__value: 170
sr/d-mfdbk/_vertical/Harmonic->__value: 80
sr/d-mfdbk/_vertical/Mode->enum_labels: "7/8+1",\ 
                                        16-bunch,\ 
                                        4-bunch,\ 
                                        Hybrid,\ 
                                        Uniform
sr/d-mfdbk/_vertical/Mode->__value: 0
sr/d-mfdbk/_vertical/SweepDwellTime->__value: 100
sr/d-mfdbk/_vertical/SweepGain->EnumLabels: 0dB,\ 
                                            -6dB,\ 
                                            -12dB,\ 
                                            -18dB,\ 
                                            -24dB,\ 
                                            -30dB,\ 
                                            -36dB,\ 
                                            -42dB,\ 
                                            -48dB,\ 
                                            -54dB,\ 
                                            -60dB,\ 
                                            -66dB,\ 
                                            -72dB,\ 
                                            -78dB,\ 
                                            -84dB,\ 
                                            -90dB
sr/d-mfdbk/_vertical/SweepGain->__value: 4
sr/d-mfdbk/_vertical/SweepRange->__value: 0.05
sr/d-mfdbk/_vertical/Tune->display_unit: 1.0
sr/d-mfdbk/_vertical/Tune->format: %6.3f
sr/d-mfdbk/_vertical/Tune->standard_unit: 1.0
sr/d-mfdbk/_vertical/Tune->__value: 0.39
sr/d-mfdbk/_vertical/TuneBunch->__value: 350
sr/d-mfdbk/_vertical/TuneOnSingleBunch->__value: false

#---------------------------------------------------------
# CLASS MBFControl properties
#---------------------------------------------------------

CLASS/MBFControl->Description: "A high level class to control MBF startup, configuration sequence and configuration file"
CLASS/MBFControl->InheritedFrom: TANGO_BASE_CLASS
CLASS/MBFControl->ProjectTitle: MBFControl

# CLASS MBFControl attribute properties



# --- dserver/MBFControl/mfdbk properties

dserver/MBFControl/mfdbk->polling_threads_pool_conf: "sr/d-mfdbk/_horizontal,sr/d-mfdbk/_vertical"
