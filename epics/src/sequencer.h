/* Sequencer sweep and detector control. */


error__t initialise_sequencer(void);

/* Called before arming the sequencer: now is the time to configure the hardware
 * for operation. */
void prepare_sequencer(int channel);


/* Information about sequencer frequency and timebase.  The tune_scale[] and
 * timebase[] arrays must be system_config.detector_length samples long. */
struct scale_info {
    double *tune_scale;
    int *timebase;
    unsigned int samples;
};

/* Reads the current scale info: this remains valid between arming events. */
const struct scale_info *read_detector_scale_info(int channel);
