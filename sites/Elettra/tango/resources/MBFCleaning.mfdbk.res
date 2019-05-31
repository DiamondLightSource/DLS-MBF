#
# Resource backup , created Thu Jun 28 12:48:37 CEST 2018
#

#---------------------------------------------------------
# SERVER MBFCleaning/mfdbk, MBFCleaning device declaration
#---------------------------------------------------------

MBFCleaning/mfdbk/DEVICE/MBFCleaning: "sr/d-mfdbk/cleaning"


# --- sr/d-mfdbk/cleaning properties

sr/d-mfdbk/cleaning->ConfigFilePath: "/operation/dserver/settings/mfdbk/cleaning"
sr/d-mfdbk/cleaning->ExternalShakerDevice: "sr/d-wave/shaker-c3-v-2"
sr/d-mfdbk/cleaning->MBFDevice: "sr/d-mfdbk/_vertical"
sr/d-mfdbk/cleaning->ScrLow25Device: "sr/d-scr/c25-low"
sr/d-mfdbk/cleaning->ScrLow5Device: "sr/d-scr/c5-low"
sr/d-mfdbk/cleaning->ScrUpp22Device: "sr/d-scr/c22-up"
sr/d-mfdbk/cleaning->ScrUpp25Device: "sr/d-scr/c25-up"
sr/d-mfdbk/cleaning->ScrUpp5Device: "sr/d-scr/c5-up"
sr/d-mfdbk/cleaning->__SubDevices: "sr/d-mfdbk/_vertical",\ 
                                   "sr/d-wave/shaker-c3-v-2"

# --- sr/d-mfdbk/cleaning attribute properties

sr/d-mfdbk/cleaning/ExternalSweep->__value: false
sr/d-mfdbk/cleaning/FreqMax->display_unit: 1.0
sr/d-mfdbk/cleaning/FreqMax->format: %7.3f
sr/d-mfdbk/cleaning/FreqMax->standard_unit: 1.0
sr/d-mfdbk/cleaning/FreqMax->__value: 417.4
sr/d-mfdbk/cleaning/FreqMin->display_unit: 1.0
sr/d-mfdbk/cleaning/FreqMin->format: %7.3f
sr/d-mfdbk/cleaning/FreqMin->standard_unit: 1.0
sr/d-mfdbk/cleaning/FreqMin->__value: 417.387
sr/d-mfdbk/cleaning/Gain->display_unit: 1.0
sr/d-mfdbk/cleaning/Gain->format: %5.2f
sr/d-mfdbk/cleaning/Gain->standard_unit: 1.0
sr/d-mfdbk/cleaning/Gain->__value: 100
sr/d-mfdbk/cleaning/Low25->format: %5.3f
sr/d-mfdbk/cleaning/Low25->__value: 8.7
sr/d-mfdbk/cleaning/Low5->format: %5.3f
sr/d-mfdbk/cleaning/Low5->__value: 11.5
sr/d-mfdbk/cleaning/Scrapers->EnumLabels: "Use Upp5 and Low5",\ 
                                          "Use Upp25 and Low25",\ 
                                          "Use Upp22"
sr/d-mfdbk/cleaning/Scrapers->__value: 0
sr/d-mfdbk/cleaning/SweepTime->__value: 20
sr/d-mfdbk/cleaning/Upp22->format: %5.3f
sr/d-mfdbk/cleaning/Upp22->__value: 15
sr/d-mfdbk/cleaning/Upp25->format: %5.3f
sr/d-mfdbk/cleaning/Upp25->__value: 21
sr/d-mfdbk/cleaning/Upp5->format: %5.3f
sr/d-mfdbk/cleaning/Upp5->__value: 11.502

#---------------------------------------------------------
# CLASS MBFCleaning properties
#---------------------------------------------------------

CLASS/MBFCleaning->Description: "A class for the bunch by bunch cleaning in the SR"
CLASS/MBFCleaning->InheritedFrom: TANGO_BASE_CLASS
CLASS/MBFCleaning->ProjectTitle: MBFCleaning

# CLASS MBFCleaning attribute properties


