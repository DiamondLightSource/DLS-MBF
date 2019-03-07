/* Hardware interfacing to MBF system. */

#define AXIS_COUNT          2       // Two independent processing axes
#define FIR_BANKS           4       // Four bunch-by-bunch selectable FIRs
#define BUNCH_BANKS         4       // Four selectable bunch configurations
#define DETECTOR_COUNT      4       // Four independed detectors
#define MAX_SEQUENCER_COUNT 7       // Steps in sequencer, not counting state 0
#define SUPER_SEQ_STATES    1024    // Max super sequencer states
#define DET_WINDOW_LENGTH   1024    // Length of sequencer detector window

#define DRAM0_LENGTH        0x80000000U     // 2GB
#define DRAM1_LENGTH        0x08000000U     // 128M

#define TRIGGER_SOURCE_COUNT    7   // Seven distinct possible trigger sources

#define MEM_CHANNEL_COUNT   2       // Memory capture uses two channels


/* Defined in register_defs.h. */
struct interrupts;


/* This structure is filled in when initialise_hardware() is called and is
 * available for use throughout the system. */
extern const struct hardware_config {
    unsigned int bunches;
    unsigned int adc_taps;
    unsigned int bunch_taps;
    unsigned int dac_taps;
    bool no_hardware;
} hardware_config;


error__t initialise_hardware(
    const char *device_address, unsigned int bunches,
    bool lock_registers, bool lmbf_mode, bool no_hardware);
void terminate_hardware(void);

/* Toggles between locked and unlocked access to the control registers. */
error__t hw_lock_registers(void);
error__t hw_unlock_registers(void);

/* Returns a mask of interrupt events, blocks until an event arrives. */
error__t hw_read_interrupt_events(struct interrupts *interrupts);


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

struct fpga_version {
    unsigned int major;
    unsigned int minor;
    unsigned int patch;
    unsigned int firmware;
    unsigned int git_sha;
    bool git_dirty;
};

/* Returns firmware version code from FPGA. */
void hw_read_fpga_version(struct fpga_version *version);

/* Reads system status registers. */
void hw_read_system_status(struct system_status *status);

/* Writes delay for revolution clock. */
void hw_write_turn_clock_idelay(unsigned int delay);

/* Direct access to FMC500 SPI devices. */
enum fmc500_spi {
    FMC500_SPI_PLL,
    FMC500_SPI_ADC,
    FMC500_SPI_DAC,
};
void hw_write_fmc500_spi(enum fmc500_spi spi, unsigned int reg, uint8_t value);
uint8_t hw_read_fmc500_spi(enum fmc500_spi spi, unsigned int reg);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Shared Control interface. */

/* Configure interaction between the two axes.  For TMBF operations the two
 * axes are independent, for LMBF operation the two axes are identical
 * with a 90 degree phase shift between them. */
void hw_write_lmbf_mode(bool lmbf_mode);

/* Configure loopback for the selected axis. */
void hw_write_loopback_enable(int axis, bool loopback);

/* Configure DAC output enable for the selected axis. */
void hw_write_output_enable(int axis, bool enable);


/* DRAM capture configuration - - - - - - - - - - - - - - - - - - - - - - - */

/* Configure capture pattern for data to DRAM0. */
void hw_write_dram_mux(unsigned int mux);

/* Configure FIR gain when capturing FIR data to DRAM0. */
void hw_write_dram_fir_gains(bool gains[AXIS_COUNT]);

/* Configures length of DRAM0 runout after trigger event. */
void hw_write_dram_runout(unsigned int count);

/* Returns trigger address from DRAM0. */
unsigned int hw_read_dram_address(void);

/* Start and stop capture to DRAM. */
void hw_write_dram_capture_command(bool start, bool stop);

/* Returns true while capture to DRAM in progress. */
bool hw_read_dram_active(void);

/* Reads memory events. */
void hw_read_dram_status(bool fir_overflow[AXIS_COUNT]);

/* Reads the specified number of samples from DRAM0 starting at the given offset
 * into the given result array, which must be at least samples entries long. */
void hw_read_dram_memory(size_t offset, size_t samples, uint32_t result[]);


/* Trigger configuration - - - - - - - - - - - - - - - - - - - - - - - - - - */

/* This defines the set of internal trigger targets. */
enum trigger_target_id {
    TRIGGER_SEQ0,
    TRIGGER_SEQ1,
    TRIGGER_DRAM,
};
#define TRIGGER_TARGET_COUNT  3       // Must match enum above!

/* At present this is a direct image of the trigger status register. */
struct trigger_status {
    bool sync_busy;
    bool seq0_armed;
    bool seq1_armed;
    bool dram_armed;
};

/* Triggers synchronisation of turn clock to external trigger. */
void hw_write_turn_clock_sync(void);

/* Requests sample of turn clock offset. */
void hw_read_turn_clock_counts(
    unsigned int *turn_count, unsigned int *error_count);

/* Delay from external turn clock to internal turn clock. */
void hw_write_turn_clock_offset(unsigned int offset);

/* Returns which incoming trigger events have occurred since the last call. */
void hw_read_trigger_events(bool sources[TRIGGER_SOURCE_COUNT], bool *blanking);

/* Simultaneous arming of the selected trigger targets. */
void hw_write_trigger_arm(const bool arm[TRIGGER_TARGET_COUNT]);

/* Simultaneous firing of the selected trigger targets. */
void hw_write_trigger_fire(const bool fire[TRIGGER_TARGET_COUNT]);

/* Simultaneous disarming of the selected trigger targets. */
void hw_write_trigger_disarm(const bool disarm[TRIGGER_TARGET_COUNT]);

/* Generate soft trigger. */
void hw_write_trigger_soft_trigger(void);

/* Reads the current trigger status. */
void hw_read_trigger_status(struct trigger_status *status);

/* Reads which trigger sources fired the selected target. */
void hw_read_trigger_sources(
    enum trigger_target_id target,
    bool sources[TRIGGER_SOURCE_COUNT]);

/* Program duration of blanking window. */
void hw_write_trigger_blanking_duration(unsigned int duration);

/* Programs the delay in turns from internal firing of trigger to delivery. */
void hw_write_trigger_delay(
    enum trigger_target_id target, unsigned int delay);

/* Configure which trigger sources will be used to trigger the selected
 * target. */
void hw_write_trigger_enable_mask(
    enum trigger_target_id target,
    const bool sources[TRIGGER_SOURCE_COUNT]);

/* Configure which trigger sources are blanked for the selected target. */
void hw_write_trigger_blanking_mask(
    enum trigger_target_id target,
    const bool sources[TRIGGER_SOURCE_COUNT]);


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
void hw_write_nco0_frequency(int axis, uint64_t frequency);


/* ADC configuration - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

struct adc_events {
    bool input_ovf;
    bool fir_ovf;
    bool delta_event;
};

/* Sets threshold for reporting ADC input overflow. */
void hw_write_adc_overflow_threshold(int axis, unsigned int threshold);

/* Sets the threshold for generating ADC bunch motion event. */
void hw_write_adc_delta_threshold(int axis, unsigned int delta);

/* Sets shift factor for ADC fill pattern reject filter. */
void hw_write_adc_reject_shift(int axis, unsigned int shift);

/* Polls the ADC events: input overflow, FIR overflow, min/max/sum overflow,
 * bunch motion event. */
void hw_read_adc_events(int axis, struct adc_events *events);

/* Sets the taps for the ADC input.  The number of taps must be as read from the
 * FPGA configuration. */
void hw_write_adc_taps(int axis, const int taps[]);

/* Set output source for ADC MMS. */
void hw_write_adc_mms_source(int axis, unsigned int source);
void hw_write_adc_dram_source(int axis, unsigned int source);

/* Reads min/max/sum for ADC. */
void hw_read_adc_mms(int axis, struct mms_result *result);


/* Bunch configuration - - - - - - - - - - - - - - - - - - - - - - - - - - - */

struct bunch_config {
    /* Each of these points to an array of bunches. */
    char *fir_select;       // Select FIR for this bunch
    int *gain;              // Output gain for this bunch
    bool *fir_enable;       // Enable FIR output for this bunch
    bool *nco0_enable;      // Enable NCO0 output for this bunch
    bool *nco1_enable;      // Enable NCO1 output (swept NCO) for this bunch
    bool *nco2_enable;      // Enable NCO2 output (Tune PLL NCO) for this bunch
};

/* Write bunch configuration. */
void hw_write_bunch_config(
    int axis, unsigned int bank, const struct bunch_config *config);

/* Programs bunch decimation factor. */
void hw_write_bunch_decimation(int axis, unsigned int decimation);

/* Write taps for bunch by bunch FIR. */
void hw_write_bunch_fir_taps(int axis, unsigned int fir, const int taps[]);

/* Checks for FIR overflow on selected axis. */
bool hw_read_bunch_overflow(int axis);


/* DAC configuration - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

struct dac_events {
    bool fir_ovf;
    bool mux_ovf;
    bool out_ovf;
};

/* Set DAC output delay. */
void hw_write_dac_delay(int axis, unsigned int delay);

/* Set output FIR gain. */
void hw_write_dac_fir_gain(int axis, unsigned int gain);

/* Set output NCO0 gain and enable. */
void hw_write_dac_nco0_gain(int axis, unsigned int gain);
void hw_write_dac_nco0_enable(int axis, bool enable);

/* Set output source for DAC memory and MMS. */
void hw_write_dac_mms_source(int axis, bool after_fir);
void hw_write_dac_dram_source(int axis, bool after_fir);

/* Returns bunch by bunch, accumulator, min/max/sum, DAC FIR overflow events. */
void hw_read_dac_events(int axis, struct dac_events *events);

/* Set DAC output FIR taps. */
void hw_write_dac_taps(int axis, const int taps[]);

/* Reads min/max/sum for DAC. */
void hw_read_dac_mms(int axis, struct mms_result *result);


/* Sequencer configuration - - - - - - - - - - - - - - - - - - - - - - - - - */

struct seq_entry {
    uint64_t start_freq;            // NCO start frequency
    uint64_t delta_freq;            // Frequency step for sweep
    unsigned int dwell_time;        // Dwell time at each step
    unsigned int capture_count;     // Number of sweep points to capture
    unsigned int bunch_bank;        // Bunch bank selection
    unsigned int nco_gain;          // Sweep output gain
    unsigned int window_rate;       // Detector window advance frequency
    bool nco_enable;                // Enable sweep output
    bool enable_window;             // Enable detector windowing
    bool write_enable;              // Enable data capture of sequence
    bool enable_blanking;           // Observe trigger holdoff control
    bool reset_phase;               // If set sweep phase is reset at start
    bool use_tune_pll;              // Enable Tune PLL frequency offset
    unsigned int holdoff;           // Detector holdoff
    unsigned int state_holdoff;     // Holdoff at start of state
};

struct seq_config {
    unsigned int bank0;
    unsigned int sequencer_pc;
    unsigned int super_seq_count;
    struct seq_entry entries[MAX_SEQUENCER_COUNT];
    int32_t window[DET_WINDOW_LENGTH];
    uint32_t super_offsets[SUPER_SEQ_STATES];
};

struct seq_state {
    bool busy;
    unsigned int pc;
    unsigned int super_pc;
};


/* Writes complete active sequencer configuration in preparation for triggered
 * operation. */
void hw_write_seq_config(int axis, const struct seq_config *config);

/* Updates the choice of bank0. */
void hw_write_seq_bank0(int axis, unsigned int bank0);

/* Configure state used to generate trigger event. */
void hw_write_seq_trigger_state(int axis, unsigned int state);

/* Resets sequencer. */
void hw_write_seq_abort(int axis);

/* Returns current sequencer state. */
void hw_read_seq_state(int axis, struct seq_state *state);


/* Detector configuration - - - - - - - - - - - - - - - - - - - - - - - - - */

/* Configuration for a single detector. */
struct detector_config {
    bool enable;                // Individual detector enables
    unsigned int scaling;       // Detector readout scaling
    bool *bunch_enables;        // Array of bunch enables
};

struct detector_result {
    int32_t i;
    int32_t q;
};

/* Writes the complete detector configuration. */
void hw_write_det_config(
    int axis, unsigned int input_select, unsigned int delay,
    const struct detector_config config[DETECTOR_COUNT]);

/* Resets detector capture address. */
void hw_write_det_start(int axis);

/* Reads events from the detector. */
void hw_read_det_events(int axis,
    bool output_ovf[DETECTOR_COUNT], bool *underrun);

/* Reads detector result in raw format. */
void hw_read_det_memory(
    int axis, unsigned int result_count, unsigned int offset,
    struct detector_result result[]);


/* Tune PLL configuration - - - - - - - - - - - - - - - - - - - - - - - - - */

/* Directly sets Tune PLL NCO frequency.  Note that setting this during feedback
 * will interfere with feedback! */
void hw_write_pll_nco_frequency(int axis, uint64_t frequency);

/* Reads current Tune PLL frequency. */
uint64_t hw_read_pll_nco_frequency(int axis);

/* Control over Tune PLL NCO gain and enable. */
void hw_write_pll_nco_gain(int axis, unsigned int gain);
void hw_write_pll_nco_enable(int axis, bool enable);

/* Control over operational parameters. */
void hw_write_pll_dwell_time(int axis, unsigned int dwell);
void hw_write_pll_target_phase(int axis, int32_t phase);
void hw_write_pll_integral_factor(int axis, int32_t integral);
void hw_write_pll_proportional_factor(int axis, int32_t proportional);
void hw_write_pll_minimum_magnitude(int axis, uint32_t magnitude);
void hw_write_pll_maximum_offset(int axis, uint32_t offset);

/* Configures the detector readout scale. */
void hw_write_pll_det_scaling(int axis, unsigned int scaling);

/* As the detector bunch offset and hence the bunch configuration depend on the
 * input selection, we have to write both together. */
void hw_write_pll_det_config(
    int axis, unsigned int input_select,
    unsigned int offset, const bool bunch_enables[]);

/* Control over debug readbacks.  If filtered CORDIC is set then the filtered IQ
 * readback will return CORDIC data, similarly if captured CORDIC is set the
 * FIFO debug data will be CORDIC data.  Only intended for CORDIC validation. */
void hw_write_pll_filtered_cordic(int axis, bool cordic);
void hw_write_pll_captured_cordic(int axis, bool cordic);

/* Start and stop Tune PLL feedback. */
void hw_write_pll_start(bool axis0, bool axis1);
void hw_write_pll_stop(bool axis0, bool axis1);


/* Read back error events. */
struct tune_pll_events {
    bool det_overflow;
    bool magnitude_error;
    bool offset_error;
};
void hw_read_pll_events(int axis, struct tune_pll_events *events);

/* Read running status and stop reasons. */
struct tune_pll_status {
    bool running;               // Set if feedback currently running
    /* The following bits are stop reasons recording why feedback is stopped. */
    bool stopped;               // Stop requested
    bool overflow;              // Detector overflow
    bool too_small;             // Magnitude too small
    bool bad_offset;            // Offset too large
};
void hw_read_pll_status(int axis, struct tune_pll_status *status);

/* Readbacks for filtered live data. */
void hw_read_pll_filtered_readbacks(
    int axis, struct detector_result *det, int32_t *offset);

/* Rather strangely, the maximum possible PLL readback FIFO capture is 1025
 * samples.  In practice this will *never* occur, but it is safest to leave the
 * space anyway. */
#define PLL_FIFO_SIZE       1025

/* Read debug and offset FIFO.  If a reset is required then *reset is set.  If
 * enable_interrupt is set then read ready interrupts are enabled on return. */
enum pll_readout_fifo {
    PLL_FIFO_DEBUG,         // Returns pairs of debug values
    PLL_FIFO_OFFSET,        // Returns frequency offsets
};
unsigned int hw_read_pll_readout_fifo(
    int axis, enum pll_readout_fifo fifo,
    bool enable_interrupt, bool *reset, int32_t data[PLL_FIFO_SIZE]);
