/* There are two configurations loaded during startup.  One defines hardware
 * delays, the other defines basic system configuration settings. */

extern const struct hardware_delays {
    bool valid;                         // If not set, all fields are zero

    unsigned int MMS_ADC_DELAY;
    unsigned int MMS_ADC_REJECT_DELAY;
    unsigned int MMS_ADC_FIR_DELAY;
    unsigned int MMS_DAC_DELAY;
    unsigned int MMS_DAC_FIR_DELAY;
    unsigned int MMS_DAC_FEEDBACK_DELAY;

    unsigned int DRAM_ADC_DELAY;
    unsigned int DRAM_ADC_REJECT_DELAY;
    unsigned int DRAM_ADC_FIR_DELAY;
    unsigned int DRAM_DAC_DELAY;
    unsigned int DRAM_FIR_DELAY;
    unsigned int DRAM_DAC_FIR_DELAY;

    unsigned int BUNCH_GAIN_OFFSET;
    unsigned int BUNCH_FIR_OFFSET;

    unsigned int DET_ADC_OFFSET;
    unsigned int DET_ADC_REJECT_OFFSET;
    unsigned int DET_FIR_OFFSET;

    int DET_ADC_DELAY;
    int DET_ADC_REJECT_DELAY;
    int DET_FIR_DELAY;

    unsigned int PLL_ADC_OFFSET;
    unsigned int PLL_FIR_OFFSET;
    unsigned int PLL_ADC_REJECT_OFFSET;

    int PLL_ADC_DELAY;
    int PLL_FIR_DELAY;
    int PLL_ADC_REJECT_DELAY;
} hardware_delays;

extern const struct system_config {
    const char *device_address;         // Name of hardware device
    const char *epics_name;             // Prefix for all EPICS names
    const char *axis0_name;             // Name of the two axes, normally
    const char *axis1_name;             // either X,Y or I,Q
    unsigned int bunches_per_turn;      // Fundamental machine parameter
    bool lmbf_mode;                     // Set if running in longitudinal mode
    double lmbf_fir_offset;             // Phase offset between FIR filters
    double revolution_frequency;        // Revolution freq in Hz for time delays
    unsigned int mms_poll_interval;     // Frequency of MMS readouts
    const char *persistence_file;       // Where to save the persistent state
    int persistence_interval;           // How often to update state (in secs)
    int pv_log_array_length;            // Manages PV logging verbosity
    int archive_interval;               // Interval for special archive PVs
    unsigned int memory_readout_length; // Length of MEM readout PVs
    unsigned int detector_length;       // Length of DET readout PVs
    unsigned int data_port;             // Socket port for fast data readout
    unsigned int tune_pll_length;       // Readout length for Tune PLL
} system_config;


error__t load_configs(
    const char *hardware_config_file, const char *system_config_file);
