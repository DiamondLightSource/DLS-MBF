#---------------------------------------------------------
# SERVER MBFControl/@@INSTANCE@@, MBFControl device declaration
#---------------------------------------------------------

MBFControl/@@INSTANCE@@/DEVICE/MBFControl: "@@DEVICE_NAME_H@@",\ 
                                    "@@DEVICE_NAME_V@@"


# --- @@DEVICE_NAME_H@@ properties

@@DEVICE_NAME_H@@->ConfigFilePath: "@@CONFIG_FILE_PATH_H@@"
@@DEVICE_NAME_H@@->DoorDevice: "@@DOOR_DEVICE_NAME_H@@"
@@DEVICE_NAME_H@@->GMBFDevice: "@@T2E_DEVICE_NAME_G@@"
@@DEVICE_NAME_H@@->MacroServerDevice: "@@MACRO_DEVICE_NAME@@"
@@DEVICE_NAME_H@@->MBFDevice: "@@T2E_DEVICE_NAME_H@@"
@@DEVICE_NAME_H@@->ModeList: "7/8+1",\ 
                                  16-bunch,\ 
                                  4-bunch,\ 
                                  Hybrid,\ 
                                  Uniform,\ 
                                  MDT_grow_damp,\ 
                                  MDT_NCO1b

# --- @@DEVICE_NAME_H@@ attribute properties

@@DEVICE_NAME_H@@/BlankingInterval->__value: 10000
@@DEVICE_NAME_H@@/CleaningFineGain->__value: 1
@@DEVICE_NAME_H@@/FeedbackFineGain->format: %4.3f
@@DEVICE_NAME_H@@/FeedbackFineGain->__value: 1
@@DEVICE_NAME_H@@/FeedbackGain->EnumLabels: 48dB,\ 
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
@@DEVICE_NAME_H@@/FeedbackGain->__value: 10
@@DEVICE_NAME_H@@/FeedbackPhase->__value: 29
@@DEVICE_NAME_H@@/Harmonic->__value: 0
@@DEVICE_NAME_H@@/Mode->enum_labels: "7/8+1",\ 
                                          16-bunch,\ 
                                          4-bunch,\ 
                                          Hybrid,\ 
                                          Uniform,\ 
                                          MDT_grow_damp,\ 
                                          MDT_NCO1b
@@DEVICE_NAME_H@@/Mode->__value: 0
@@DEVICE_NAME_H@@/SweepDwellTime->__value: 100
@@DEVICE_NAME_H@@/SweepGain->EnumLabels: 0dB,\ 
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
@@DEVICE_NAME_H@@/SweepGain->__value: 8
@@DEVICE_NAME_H@@/SweepRange->__value: 0.05
@@DEVICE_NAME_H@@/Tune->__value: 0.44
@@DEVICE_NAME_H@@/TuneBunch->__value: 500
@@DEVICE_NAME_H@@/TuneOnSingleBunch->__value: false

# --- @@DEVICE_NAME_V@@ properties

@@DEVICE_NAME_V@@->ConfigFilePath: "@@CONFIG_FILE_PATH_V@@"
@@DEVICE_NAME_V@@->DoorDevice: "@@DOOR_DEVICE_NAME_V@@"
@@DEVICE_NAME_V@@->GMBFDevice: "@@T2E_DEVICE_NAME_G@@"
@@DEVICE_NAME_V@@->MacroServerDevice: "@@MACRO_DEVICE_NAME@@"
@@DEVICE_NAME_V@@->MBFDevice: "@@T2E_DEVICE_NAME_V@@"
@@DEVICE_NAME_V@@->ModeList: "7/8+1",\ 
                                16-bunch,\ 
                                4-bunch,\ 
                                Hybrid,\ 
                                Uniform,\ 
                                MDT_grow_damp,\ 
                                MDT_NCO1b

# --- @@DEVICE_NAME_V@@ attribute properties

@@DEVICE_NAME_V@@/BlankingInterval->__value: 10000
@@DEVICE_NAME_V@@/CleaningFineGain->__value: 1
@@DEVICE_NAME_V@@/FeedbackFineGain->format: %4.3f
@@DEVICE_NAME_V@@/FeedbackFineGain->__value: 1
@@DEVICE_NAME_V@@/FeedbackGain->EnumLabels: 48dB,\ 
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
@@DEVICE_NAME_V@@/FeedbackGain->__value: 5
@@DEVICE_NAME_V@@/FeedbackPhase->__value: -99
@@DEVICE_NAME_V@@/Harmonic->__value: 991
@@DEVICE_NAME_V@@/Mode->enum_labels: "7/8+1",\ 
                                        16-bunch,\ 
                                        4-bunch,\ 
                                        Hybrid,\ 
                                        Uniform,\ 
                                        MDT_grow_damp,\ 
                                        MDT_NCO1b
@@DEVICE_NAME_V@@/Mode->__value: 5
@@DEVICE_NAME_V@@/SweepDwellTime->__value: 100
@@DEVICE_NAME_V@@/SweepGain->EnumLabels: 0dB,\ 
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
@@DEVICE_NAME_V@@/SweepGain->__value: 8
@@DEVICE_NAME_V@@/SweepRange->display_unit: 1.0
@@DEVICE_NAME_V@@/SweepRange->format: %6.3f
@@DEVICE_NAME_V@@/SweepRange->standard_unit: 1.0
@@DEVICE_NAME_V@@/SweepRange->__value: 0.05
@@DEVICE_NAME_V@@/Tune->display_unit: 1.0
@@DEVICE_NAME_V@@/Tune->format: %6.3f
@@DEVICE_NAME_V@@/Tune->standard_unit: 1.0
@@DEVICE_NAME_V@@/Tune->__value: 0.39
@@DEVICE_NAME_V@@/TuneBunch->__value: 0
@@DEVICE_NAME_V@@/TuneOnSingleBunch->__value: false

#---------------------------------------------------------
# CLASS MBFControl properties
#---------------------------------------------------------

CLASS/MBFControl->Description: "A high level class to control MBF startup, configuration sequence and configuration file"
CLASS/MBFControl->InheritedFrom: TANGO_BASE_CLASS
CLASS/MBFControl->ProjectTitle: MBFControl

# CLASS MBFControl attribute properties



# --- dserver/MBFControl/@@INSTANCE@@ properties

dserver/MBFControl/@@INSTANCE@@->polling_threads_pool_conf: "@@DEVICE_NAME_H@@,@@DEVICE_NAME_V@@"
