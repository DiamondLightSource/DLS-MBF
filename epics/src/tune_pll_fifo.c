/* Support for Tune PLL FIFOs. */

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <pthread.h>

#include "error.h"
#include "epics_device.h"
#include "epics_extra.h"

#include "register_defs.h"
#include "hardware.h"
#include "common.h"

#include "tune_pll_fifo.h"


struct readout_fifo {
    /* Hardware FIFO identification. */
    int axis;                           // Selects which axis
    enum pll_readout_fifo fifo;         // Selects which hardware FIFO to read

    /* EPICS processing handshake. */
    struct epics_interlock *interlock;  // Signal for EPICS processing
    bool epics_busy;                    // Set if EPICS processing is active

    /* Buffer of full FIFO capture ready for EPICS processing. */
    int32_t *buffer;                    // Data captured ready for EPICS output
    unsigned int buffer_size;           // Buffer capacity
    unsigned int buffer_count;          // Current number of samples in buffer

    /* FIFO processing state. */
    bool enabled;
    bool overflow;                      // Hardware FIFO overrun detected
    pthread_mutex_t mutex;              // Needed for managed access

    /* Optional buffer processing callback. */
    void (*process_buffer)(void *context);
    void *context;

    /* Read buffer for initial data capture. */
    unsigned int read_buffer_count;     // Number of hold-over samples
    int32_t read_buffer[PLL_FIFO_SIZE]; // Buffer of hold-over samples
};


/* Ensures that the FIFO is not being processed by EPICS, returns true if it was
 * busy. */
static bool ensure_epics_idle(struct readout_fifo *fifo)
{
    bool busy = fifo->epics_busy;
    if (busy)
    {
        interlock_wait(fifo->interlock);
        fifo->epics_busy = false;
    }
    return busy;
}


enum process_stage {
    PROCESS_START,
    PROCESS_UPDATE,
    PROCESS_STOP,
};

/* Performs FIFO data processing, triggered either by data ready interrupt or on
 * disable event.  MUST be called with mutex held.
 *
 * This is called when the FIFO is ready to read.  We read what data is
 * available, update our waveforms and notify EPICS as appropriate, and reenable
 * interrupts for our next call. */
static void process_fifo_content(
    struct readout_fifo *fifo, enum process_stage stage)
{
    /* Ensure that any EPICS processing has completed. */
    if (ensure_epics_idle(fifo))
    {
        /* Copy any residue from our buffer into the read buffer. */
        memcpy(fifo->buffer, fifo->read_buffer,
            fifo->read_buffer_count * sizeof(int32_t));
        fifo->buffer_count = fifo->read_buffer_count;
        /* Resetting read_buffer_count is optional as we only observe it when
         * epics_busy is set! */
    }

    /* Read what there is to read.  Enable interrupts unless stopping. */
    bool enable_interrupts = stage != PROCESS_STOP;
    unsigned int samples = hw_read_pll_readout_fifo(
        fifo->axis, fifo->fifo, enable_interrupts,
        &fifo->overflow, fifo->read_buffer);

    /* Update the buffer. */
    unsigned int to_copy =
        MIN(samples, fifo->buffer_size - fifo->buffer_count);
    memcpy(&fifo->buffer[fifo->buffer_count], fifo->read_buffer,
        to_copy * sizeof(int32_t));
    fifo->buffer_count += to_copy;

    /* Emit the buffer if appropriate: if the buffer is full, if this is the
     * last ready, or if there has been an overflow ... except for the first
     * read, in which case we ignore the overflow. */
    bool emit_buffer =
        stage == PROCESS_STOP  ||
        fifo->buffer_count == fifo->buffer_size  ||
        (fifo->overflow  &&  stage != PROCESS_START);
    if (emit_buffer)
    {
        fifo->epics_busy = true;
        if (fifo->process_buffer)
            fifo->process_buffer(fifo->context);
        interlock_signal(fifo->interlock, NULL);

        /* Hang onto anything we didn't copy. */
        fifo->read_buffer_count = samples - to_copy;
        memmove(fifo->read_buffer, &fifo->read_buffer[to_copy],
            fifo->read_buffer_count * sizeof(int32_t));
    }
}


static void reset_fifo(
    struct readout_fifo *fifo, bool flush_hardware, bool enable_interrupt)
{
    /* Reset the FIFO state. */
    fifo->buffer_count = 0;
    fifo->overflow = false;

    /* Read and discard FIFO content, resetting if necessary. */
    if (flush_hardware)
    {
        bool overflow;
        hw_read_pll_readout_fifo(
            fifo->axis, fifo->fifo, enable_interrupt,
            &overflow, fifo->read_buffer);
    }
}


/* Start the FIFO readout process by clearing and resetting the FIFO and
 * enabling interrupts.  Must be called with mutex held and fifo disabled. */
static void start_readout_fifo(struct readout_fifo *fifo, bool flush)
{
    /* First ensure EPICS is not active. */
    ensure_epics_idle(fifo);

    fifo->enabled = true;
    reset_fifo(fifo, flush, true);

    /* Set the FIFO running. */
    process_fifo_content(fifo, PROCESS_START);
}


/* Reset the FIFO by discarding any buffered data.  This is used to arrange for
 * a completely fresh buffer readout. */
static void flush_readout_fifo(struct readout_fifo *fifo)
{
    /* First ensure EPICS is not active. */
    ensure_epics_idle(fifo);
    reset_fifo(fifo, true, true);
}


/* Disable the FIFO readout.  Must be called with mutex held. */
static void stop_readout_fifo(struct readout_fifo *fifo)
{
    process_fifo_content(fifo, PROCESS_STOP);
    fifo->enabled = false;
}


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/* The following are the interface methods to the FIFO above. */


struct readout_fifo *create_readout_fifo(
    int axis, enum pll_readout_fifo which_fifo, unsigned int buffer_size,
    void (*process_buffer)(void *context), void *context)
{
    struct readout_fifo *fifo = malloc(sizeof(struct readout_fifo));
    *fifo = (struct readout_fifo) {
        .axis = axis,
        .fifo = which_fifo,
        .interlock = create_interlock("READ", false),
        .buffer_size = buffer_size,
        .buffer = CALLOC(int32_t, buffer_size),
        .mutex = PTHREAD_MUTEX_INITIALIZER,
        .process_buffer = process_buffer,
        .context = context,
    };

    reset_fifo(fifo, true, false);
    PUBLISH_READ_VAR(bi, "FIFO_OVF", fifo->overflow);
    return fifo;
}


void enable_readout_fifo(struct readout_fifo *fifo, bool flush)
{
    WITH_MUTEX(fifo->mutex)
        if (!fifo->enabled)
            start_readout_fifo(fifo, flush);
}


void disable_readout_fifo(struct readout_fifo *fifo)
{
    WITH_MUTEX(fifo->mutex)
        if (fifo->enabled)
            stop_readout_fifo(fifo);
}


void reset_readout_fifo(struct readout_fifo *fifo)
{
    WITH_MUTEX(fifo->mutex)
        if (fifo->enabled)
            flush_readout_fifo(fifo);
}


void handle_fifo_ready(struct readout_fifo *fifo)
{
    WITH_MUTEX(fifo->mutex)
        if (fifo->enabled)
            process_fifo_content(fifo, PROCESS_UPDATE);
}


unsigned int read_fifo_buffer(
    struct readout_fifo *fifo, const int32_t **buffer)
{
    ASSERT_OK(fifo->epics_busy);
    *buffer = fifo->buffer;
    return fifo->buffer_count;
}
