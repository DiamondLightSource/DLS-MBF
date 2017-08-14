/* Fast memory readout support. */

error__t initialise_memory(void);

/* This is called before arming the MEM trigger destination. */
void prepare_memory(void);

/* ADC and DAC outputs need to let DRAM know about output delays. */
void set_memory_dac_offset(int channel, unsigned int delay);
void set_memory_adc_offset(int channel, unsigned int delay);
