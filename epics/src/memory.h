/* Fast memory readout support. */

error__t initialise_memory(void);

/* This is called before arming the MEM trigger destination. */
void prepare_memory(void);

/* DAC output needs to let DRAM know about its output delay. */
void set_memory_dac_offset(int channel, unsigned int delay);
