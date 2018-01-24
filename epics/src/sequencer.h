/* Sequencer sweep and detector control. */


error__t initialise_sequencer(void);

/* Called before arming the sequencer: now is the time to configure the hardware
 * for operation. */
void prepare_sequencer(int axis);


/* Information about sequencer frequency and timebase.  The tune_scale[] and
 * timebase[] arrays must be system_config.detector_length samples long. */
struct scale_info {
    double *tune_scale;
    int *timebase;
    unsigned int samples;
};

/* Reads the current scale info.  This is valid for the current acquisition
 * after prepare_sequencer() has been called. */
void read_detector_scale_info(
    int axis, unsigned int length, struct scale_info *info);

/* Computes raw frequency and timebase information for the detector.  Either
 * destination waveform can be NULL, and only samples starting at position
 * offset are written. */
unsigned int compute_scale_info(
    int axis, unsigned int frequency[], unsigned int timebase[],
    unsigned int offset, unsigned int length);

/* Returns currently configured bank zero for given axis. */
unsigned int get_seq_idle_bank(int axis);
