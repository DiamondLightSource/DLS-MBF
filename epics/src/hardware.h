/* Hardware interfacing to LMBF system. */

#define CHANNEL_COUNT       2       // Two independent processing channels
#define FIR_BANKS           4       // Four bunch-by-bunch selectable FIRs
#define BUNCH_BANKS         4       // Four selectable bunch configurations
#define DETECTOR_COUNT      4       // Four independed detectors
#define MAX_SEQUENCER_COUNT 7       // Steps in sequencer, not counting state 0
#define SUPER_SEQ_STATES    1024    // Max super sequencer states
#define DET_WINDOW_LENGTH   1024    // Length of sequencer detector window

#define DRAM0_LENGTH        0x80000000U     // 2GB
#define DRAM1_LENGTH        0x08000000U     // 128M


/* This structure is filled in when initialise_hardware() is called and is
 * available for use throughout the system. */
extern const struct hardware_config {
    unsigned int bunches;
    unsigned int adc_taps;
    unsigned int bunch_taps;
    unsigned int dac_taps;
} hardware_config;


error__t initialise_hardware(
    const char *prefix, unsigned int bunches, bool lock_registers);
void terminate_hardware(void);

/* Toggles between locked and unlocked access to the control registers. */
error__t hw_lock_registers(void);
error__t hw_unlock_registers(void);

/* Returns device node name for direct access to fast DRAM. */
error__t hw_read_fast_dram_name(char *name, size_t length);

/* Returns a mask of interrupt events, blocks until an event arrives. */
error__t hw_read_interrupt_events(unsigned int *events);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* System interface. */

struct system_status {
    bool dsp_ok;
    bool vcxo_ok;
    bool adc_ok;
    bool dac_ok;
    bool vcxo_locked;
    bool vco_locked;
    bool dac_irq;
    bool temp_alert;
};

/* Returns firmware version code from FPGA. */
uint32_t hw_read_fpga_version(void);

/* Reads system status registers. */
void hw_read_system_status(struct system_status *status);

/* Allows fine control over revolution clock input delay. */
void hw_write_rev_clk_idelay(unsigned int delay);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Shared Control interface. */

/* This structure is used to define the interaction between the two channels. */
struct channel_config {
    bool adc_mux;           // If set copy ADC1 to FIR0 input
    bool nco0_mux;          // If set copy NCO0 sin to channel 1
    bool nco1_mux;          // If set copy NCO1 sin to channel 1
    bool bank_mux;          // If set copy channel 1 bank selection to channel 0
};

/* Configure interaction between the two channels.  For TMBF operations the two
 * channels are independent, for LMBF operation the two channels are identical
 * with a 90 degree phase shift between them. */
void hw_write_channel_config(const struct channel_config *config);

/* Configure loopback for the selected channel. */
void hw_write_loopback_enable(int channel, bool loopback);

/* Configure DAC output enable for the selected channel. */
void hw_write_output_enable(int channel, bool enable);


/* DRAM capture configuration - - - - - - - - - - - - - - - - - - - - - - - */

/* Configure capture pattern for data to DRAM0. */
void hw_write_dram_mux(unsigned int mux);

/* Configure FIR gain when capturing FIR data to DRAM0. */
void hw_write_dram_fir_gain(unsigned int gain);

/* Configures length of DRAM0 runout after trigger event. */
void hw_write_dram_runout(unsigned int count);

/* Returns trigger address from DRAM0. */
unsigned int hw_read_dram_address(void);

/* Start and stop capture to DRAM. */
void hw_write_dram_capture_command(bool start, bool stop);

/* Returns true while capture to DRAM in progress. */
bool hw_read_dram_active(void);

/* Reads the specified number of samples from DRAM0 starting at the given offset
 * into the given result array, which must be at least samples entries long. */
void hw_read_dram_memory(size_t offset, size_t samples, uint32_t result[]);


/* Trigger configuration - - - - - - - - - - - - - - - - - - - - - - - - - - */

/* These are the available sources of trigger events. */
struct trigger_sources {
    bool soft;              // Software generated trigger
    bool external;          // External trigger on DIO input 0
    bool postmortem;        // Postmortem trigger on DIO input 1
    bool adc0_motion;       // ADC input motion event
    bool adc1_motion;
    bool state0;            // Sequencer state event
    bool state1;
};

/* This defines the set of internal trigger destinations. */
enum trigger_destination {
    TRIGGER_SEQ0,
    TRIGGER_SEQ1,
    TRIGGER_DRAM,
};

/* At present this is a direct image of the trigger status register. */
struct trigger_status {
    bool sync_busy;
    bool sync_phase;
    bool sync_error;
    bool sample_busy;
    bool sample_phase;
    bool seq0_armed;
    bool seq1_armed;
    bool dram_armed;
    unsigned int clock_offset;
};

/* Triggers synchronisation of turn clock to external trigger. */
void hw_write_turn_clock_sync(void);

/* Requests sample of turn clock offset. */
void hw_write_turn_clock_sample(void);

/* Delay from external turn clock to internal turn clock. */
void hw_write_turn_clock_offset(int channel, unsigned int offset);

/* Returns which incoming trigger events have occurred since the last call. */
void hw_read_trigger_events(struct trigger_sources *sources);

/* Simultaneous arming of the selected trigger destinations. */
void hw_write_trigger_arm(bool arm_seq0, bool arm_seq1, bool arm_dram);

/* Simultaneous disarming of the selected trigger destinations. */
void hw_write_trigger_disarm(
    bool disarm_seq0, bool disarm_seq1, bool disarm_dram);

/* Generate soft trigger. */
void hw_write_trigger_soft_trigger(void);

/* Reads the current trigger status. */
void hw_read_trigger_status(struct trigger_status *status);

/* Configures which sources are enabled for the selected destination. */
void hw_write_trigger_sources(
    enum trigger_destination destination,
    const struct trigger_sources *sources);

/* Program duration of blanking window. */
void hw_write_trigger_blanking_duration(int channel, unsigned int duration);

/* Programs the delay in turns from internal firing of trigger to delivery. */
void hw_write_trigger_delay(
    enum trigger_destination destination, unsigned int delay);

/* Configure which trigger sources will be used to trigger the selected
 * destination. */
void hw_write_trigger_enable_mask(
    enum trigger_destination destination,
    const struct trigger_sources *sources);

/* Configure which trigger sources are blanked for the selected destination. */
void hw_write_trigger_blanking_mask(
    enum trigger_destination destination,
    const struct trigger_sources *sources);

/* Configure the turn clock and blanking pulse used for DRAM triggering. */
void hw_write_trigger_dram_select(
    int turn_channel, const bool blanking[CHANNEL_COUNT]);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* DSP interface. */

/* This structure is used to contain the result of reading from the ADC and DAC
 * min/max/sum unit. */
struct mms_result {
    unsigned int turns;     // Number of turns in this readout
    bool turns_ovfl;        // Set if turn counter has overflowed
    bool sum_ovfl;          // Set if any sum field overflowed
    bool sum2_ovfl;         // Set if any sum of squares field overflowed

    /* The following must all be set to point to arrays containing bunches
     * fields. */
    int16_t *minimum;       // Minimum value of bunch
    int16_t *maximum;       // Maximum value of bunch
    int32_t *sum;           // Sum of bunch over captured turns
    uint64_t *sum2;         // Sum of squares of bunch
};

/* Directly sets the fixed frequency oscillator. */
void hw_write_nco0_frequency(int channel, unsigned int frequency);


/* ADC configuration - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

struct adc_events {
    bool input_ovf;
    bool fir_ovf;
    bool mms_ovf;
    bool delta_event;
};

/* Sets threshold for reporting ADC input overflow. */
void hw_write_adc_overflow_threshold(int channel, unsigned int threshold);

/* Sets the threshold for generating ADC bunch motion event. */
void hw_write_adc_delta_threshold(int channel, unsigned int delta);

/* Enable new delta triggering event. */
void hw_write_adc_arm_delta(int channel);

/* Polls the ADC events: input overflow, FIR overflow, min/max/sum overflow,
 * bunch motion event. */
void hw_read_adc_events(int channel, struct adc_events *events);

/* Sets the taps for the ADC input.  The number of taps must be as read from the
 * FPGA configuration. */
void hw_write_adc_taps(int channel, const int taps[]);

/* Reads min/max/sum for ADC. */
void hw_read_adc_mms(int channel, struct mms_result *result);


/* Bunch configuration - - - - - - - - - - - - - - - - - - - - - - - - - - - */

struct bunch_config {
    /* Each of these points to an array of bunches. */
    char *fir_select;       // Select FIR for this bunch
    int *gain;              // Output gain for this bunch
    bool *fir_enable;       // Enable FIR output for this bunch
    bool *nco0_enable;      // Enable NCO0 output for this bunch
    bool *nco1_enable;      // Enable NCO1 output for this bunch
};

/* Write bunch configuration. */
void hw_write_bunch_config(
    int channel, unsigned int bank, const struct bunch_config *config);

/* Programs bunch decimation factor. */
void hw_write_bunch_decimation(int channel, unsigned int decimation);

/* Write taps for bunch by bunch FIR. */
void hw_write_bunch_fir_taps(int channel, unsigned int fir, const int taps[]);


/* DAC configuration - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

struct dac_events {
    bool fir_ovf;
    bool mux_ovf;
    bool mms_ovf;
    bool out_ovf;
};

/* Set DAC output delay. */
void hw_write_dac_delay(int channel, unsigned int delay);

/* Set output FIR gain. */
void hw_write_dac_fir_gain(int channel, unsigned int gain);

/* Set output NCO0 gain. */
void hw_write_dac_nco0_gain(int channel, unsigned int gain);

/* Global enables for DAC output, globally disables selected outputs. */
void hw_write_dac_fir_enable(int channel, bool enable);
void hw_write_dac_nco0_enable(int channel, bool enable);
void hw_write_dac_nco1_enable(int channel, bool enable);

/* Returns bunch by bunch, accumulator, min/max/sum, DAC FIR overflow events. */
void hw_read_dac_events(int channel, struct dac_events *events);

/* Set DAC output FIR taps. */
void hw_write_dac_taps(int channel, const int taps[]);

/* Reads min/max/sum for DAC. */
void hw_read_dac_mms(int channel, struct mms_result *result);


/* Sequencer configuration - - - - - - - - - - - - - - - - - - - - - - - - - */

struct seq_entry {
    unsigned int start_freq;        // NCO start frequency
    unsigned int delta_freq;        // Frequency step for sweep
    unsigned int dwell_time;        // Dwell time at each step
    unsigned int capture_count;     // Number of sweep points to capture
    unsigned int bunch_bank;        // Bunch bank selection
    unsigned int nco_gain;          // HOM output gain
    unsigned int window_rate;       // Detector window advance frequency
    bool enable_window;             // Enable detector windowing
    bool write_enable;              // Enable data capture of sequence
    bool enable_blanking;           // Observe trigger holdoff control
    unsigned int holdoff;           // Detector holdoff
};

/* Rewrites the sequencer table.  If entries is NULL then only bank0 is updated,
 * otherwise the entire sequencer table is written. */
void hw_write_seq_entries(
    int channel, unsigned int bank0,
    const struct seq_entry entries[MAX_SEQUENCER_COUNT]);

/* Configures super sequencer: writes array of sweep frequency offsets. */
void hw_write_seq_super_entries(
    int channel, unsigned int count, const uint32_t offsets[SUPER_SEQ_STATES]);

/* Writes detector window. */
void hw_write_seq_window(int channel, const int window[DET_WINDOW_LENGTH]);

/* Programs sequencer program counter. */
void hw_write_seq_count(int channel, unsigned int sequencer_pc);

/* Programs number of super sequencer states. */
void hw_write_seq_super_count(int channel, unsigned int super_count);

/* Returns current sequencer state. */
void hw_read_seq_state(
    int channel, bool *busy, unsigned int *pc, unsigned int *super_pc);

/* Resets sequencer. */
void hw_write_seq_abort(int channel);

/* Configure state used to generate trigger event. */
void hw_write_seq_trigger_state(int channel, unsigned int state);


/* Detector configuration - - - - - - - - - - - - - - - - - - - - - - - - - */

/* Sets the FIR gain for the detector input. */
void hw_write_det_fir_gain(int channel, bool gain);

/* Choose between FIR and ADC input. */
void hw_write_det_input_select(int channel, bool fir_adcn);

/* Determine whether selected detector is used for data capture. */
void hw_write_det_output_enable(int channel, int det, bool enable);

/* Determine output scaling for selected detector. */
void hw_write_det_output_gain(int channel, int det, unsigned int gain);

/* Reads events from the detector. */
void hw_read_det_events(int channel,
    bool output_ovf[DETECTOR_COUNT], bool underrun[DETECTOR_COUNT],
    bool fir_ovf[DETECTOR_COUNT]);

/* Configures bunch enables for selected detector. */
void hw_write_det_bunch_enable(int channel, int det, const bool enables[]);

/* Resets detector capture address. */
void hw_write_det_start(int channel);
