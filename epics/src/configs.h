/* There are two configurations loaded during startup.  One defines hardware
 * delays, the other defines basic system configuration settings. */

extern const struct hardware_delays {
    unsigned int adc_mms_offset;
    unsigned int dac_mms_offset;
    unsigned int bunch_fir_offset;
    unsigned int bunch_out_offset;
    unsigned int bunch_gain_offset;
} hardware_delays;

extern const struct system_config {
    const char *epics_name;
    const char *channel0_name;
    const char *channel1_name;
    unsigned int bunches_per_turn;
    double revolution_frequency;
    unsigned int mms_poll_interval;
    const char *persistence_file;
    int persistence_interval;
    int pv_log_array_length;
    unsigned int memory_readout_length;
} system_config;


error__t load_configs(
    const char *hardware_config_file, const char *system_config_file);
