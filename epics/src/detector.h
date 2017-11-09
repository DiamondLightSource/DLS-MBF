/* Detector control. */

error__t initialise_detector(void);

/* Called before arming the detector. */
void prepare_detector(int channel);

/* Returns number of detector channels and samples for given channel. */
void get_detector_samples(
    int channel, unsigned int *channels, unsigned int *samples);
