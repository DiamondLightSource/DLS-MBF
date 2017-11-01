/* There are two configurations loaded during startup.  One defines hardware
 * delays, the other defines basic system configuration settings. */

extern const struct hardware_delays {
    unsigned int MMS_ADC_DELAY;
    unsigned int MMS_ADC_FIR_DELAY;
    unsigned int MMS_DAC_DELAY;
    unsigned int MMS_DAC_FIR_DELAY;

    unsigned int DRAM_ADC_DELAY;
    unsigned int DRAM_ADC_FIR_DELAY;
    unsigned int DRAM_DAC_DELAY;
    unsigned int DRAM_FIR_DELAY;
    unsigned int DRAM_DAC_FIR_DELAY;

    unsigned int BUNCH_GAIN_OFFSET;
    unsigned int BUNCH_FIR_OFFSET;

    unsigned int DET_ADC_OFFSET;
    unsigned int DET_FIR_OFFSET;
} hardware_delays;

extern const struct system_config {
    const char *device_address;
    const char *epics_name;
    const char *channel0_name;
    const char *channel1_name;
    unsigned int bunches_per_turn;
    bool lmbf_mode;
    double lmbf_fir_offset;
    double revolution_frequency;
    unsigned int mms_poll_interval;
    const char *persistence_file;
    int persistence_interval;
    int pv_log_array_length;
    unsigned int memory_readout_length;
    unsigned int detector_length;
} system_config;


error__t load_configs(
    const char *hardware_config_file, const char *system_config_file);
