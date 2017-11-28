/* Detector control. */

error__t initialise_detector(void);

/* Called before arming the detector. */
void prepare_detector(int channel);


struct detector_info {
    unsigned int detector_mask;     // Mask of active detector channels
    unsigned int detector_count;    // Number of channels captured into memory
    unsigned int samples;           // Number of samples captured
    int delay;                      // Detector skew in samples
};

/* Returns number of detector channels and samples for given channel. */
void get_detector_info(int channel, struct detector_info *info);
