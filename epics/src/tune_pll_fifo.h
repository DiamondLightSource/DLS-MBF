/* Support for Tune PLL FIFOs. */

struct readout_fifo;

/* This is called to create a wrapper around a hardware readout FIFO, identified
 * by (axis, which_fifo).
 *
 * The associated database definitions must include a READ and a FIFO_OVF
 * record, defined thus:
 *
 *      Trigger('READ',
 *          ...,
 *          overflow('FIFO_OVF', 'FIFO readout overrun'))
 */
struct readout_fifo *create_readout_fifo(
    int axis, enum pll_readout_fifo which_fifo, unsigned int buffer_size);

/* This should be called each time a FIFO ready read interrupt is seend. */
void handle_fifo_ready(struct readout_fifo *fifo);

/* Enables the FIFO.  The FIFO should be enabled *before* the hardware is
 * enabled.  If flush is true then the hardware FIFO is flushed as part of the
 * startup process. */
void enable_readout_fifo(struct readout_fifo *fifo, bool flush);

/* Disables the FIFO.  The FIFO should be disabled *after* the hardware has
 * stopped. */
void disable_readout_fifo(struct readout_fifo *fifo);

/* Restarts reading of the FIFO by discarding any data currently in hand and
 * reading out and discarding the hardware buffer. */
void reset_readout_fifo(struct readout_fifo *fifo);

/* Returns length of current FIFO readback buffer.  Should only be called from
 * EPICS callbacks triggered by the READ trigger. */
unsigned int read_fifo_buffer(
    struct readout_fifo *fifo, const int32_t **buffer);
