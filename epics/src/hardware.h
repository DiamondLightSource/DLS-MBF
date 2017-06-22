/* Hardware interfacing to LMBF system. */

error__t initialise_hardware(const char *prefix, const char *config);
void terminate_hardware(void);

/* Returns device node name for direct access to fast DRAM. */
error__t hw_read_fast_dram_name(char *name, size_t length);

/* Returns firmware version code from FPGA. */
uint32_t hw_read_fpga_version(void);
