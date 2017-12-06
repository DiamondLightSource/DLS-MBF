/* Reads from fast memory. */
error__t process_memory_command(
    struct buffered_file *file, bool raw_mode, const char *command);

/* Reads from detector. */
error__t process_detector_command(
    struct buffered_file *file, bool raw_mode, const char *command);
