/* Detector control. */

error__t initialise_detector(void);

/* Called before arming the detector. */
void prepare_detector(int axis);


struct detector_info {
    unsigned int detector_mask;     // Mask of active detector axes
    unsigned int detector_count;    // Number of axes captured into memory
    unsigned int samples;           // Number of samples captured
    int delay;                      // Detector skew in samples
};

/* Returns number of detector axes and samples for given axis. */
void get_detector_info(int axis, struct detector_info *info);

/* Returns the current configuration of the selected detector. */
const struct detector_config *get_detector_config(int axis, int detector);
