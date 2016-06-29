/* Interrupt handling. */

#include <linux/pci.h>
#include <linux/interrupt.h>
#include <linux/sched.h>
#include <linux/wait.h>
#include <linux/atomic.h>

#include "error.h"
#include "dma_control.h"
#include "interrupts.h"


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/* Register space for AXI interrupt controller (Xilinx AXI Interrupt Controller
 * (INTC), documentation: PG099). */
struct axi_interrupt_controller {
    uint32_t isr;               // 00 Interrupt status
    uint32_t ipr;               // 04 Interrupt pending
    uint32_t ier;               // 08 Interrupt enable
    uint32_t iar;               // 0C Interrupt acknowledge
    uint32_t sie;               // 10 Set interrupt enables
    uint32_t cie;               // 14 Clear interrupt enables
    uint32_t ivr;               // 18 Interrupt vector
    uint32_t mer;               // 1C Master enable
    uint32_t imr;               // 20 Intterupt mode
    uint32_t ilr;               // 24 Interrupt level
};


struct interrupt_control {
    /* Interrupt controller register space. */
    struct axi_interrupt_controller __iomem *intc;
    /* Handle for DMA interrupt event. */
    struct dma_control *dma;

    /* Wait queue for user-space interrupt events. */
    wait_queue_head_t wait_queue;
    /* Set of user-space events seen. */
    atomic_t events;
};


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


bool interrupt_events_ready(struct interrupt_control *control)
{
    return atomic_read(&control->events);
}


int read_interrupt_events(
    struct interrupt_control *control, bool no_wait, char *events)
{
    if (no_wait)
    {
        *events = (char) atomic_xchg(&control->events, 0);
        return 0;
    }
    else
        /* Tricksy code here: we rely on the side effect of the condition,
         * because we want to genuinely get the current value.  This ensures
         * that we'll never return a non zero value unless no_wait is true. */
        return wait_event_interruptible(
            control->wait_queue,
            (*events = (char) atomic_xchg(&control->events, 0)));
}


wait_queue_head_t *interrupts_wait_queue(struct interrupt_control *control)
{
    return &control->wait_queue;
}


/* Stores user space interrupt events and notifies as appropriate. */
static void event_interrupt(struct interrupt_control *control, uint32_t events)
{
    /* Add the new events into the current event mask. */
    int old_events;
    do
        old_events = atomic_read(&control->events);
    while (atomic_cmpxchg(
        &control->events, old_events, old_events | events) != old_events);

    /* Let any listeners know. */
    wake_up_interruptible(&control->wait_queue);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static irqreturn_t lmbf_isr(int ireq, void *context)
{
    struct interrupt_control *control = context;
    struct axi_interrupt_controller *intc = control->intc;

    /* Ask the interrupt controller for the active interrupts and acknowlege the
     * ones we've seen. */
    uint32_t isr = readl(&intc->isr);
    writel(isr, &intc->iar);

    /* Interrupt number 1 belongs to the DMA engine. */
    if (isr & 1)
        dma_interrupt(control->dma);

    /* The remaining interrupts are handed on to the event source. */
    isr >>= 1;
    if (isr)
        event_interrupt(control, isr);

    return IRQ_HANDLED;
}


int initialise_interrupt_control(
    struct pci_dev *pdev, void __iomem *regs,
    struct dma_control *dma,
    struct interrupt_control **pcontrol)
{
    int rc = 0;

    /* Allocate memory for interrupt state. */
    struct interrupt_control *control =
        kmalloc(sizeof(struct interrupt_control), GFP_KERNEL);
    TEST_PTR(control, rc, no_memory, "Unable to allocate interrupt control");
    *control = (struct interrupt_control) {
        .intc = regs,
        .dma = dma,
        .events = (atomic_t) ATOMIC_INIT(0),
    };
    *pcontrol = control;

    init_waitqueue_head(&control->wait_queue);

    /* Start with the interrupt controller disabled while we internally enable
     * everything and clear any acknowleges. */
    struct axi_interrupt_controller *intc = control->intc;
    writel(0, &intc->mer);              // Disable controller
    writel(0xFFFFFFFF, &intc->iar);     // Ensure no pending interrupts
    writel(0xFFFFFFFF, &intc->ier);     // Enable all interrupts

    rc = request_irq(pdev->irq, lmbf_isr, 0, DEVICE_NAME, control);
    TEST_RC(rc, no_irq, "Unable to request irq");

    /* Put the controller in normal operating mode. */
    writel(3, &intc->mer);              // Enable controller

    return 0;

    free_irq(pdev->irq, control);
no_irq:
    kfree(control);
no_memory:
    return rc;
}


void terminate_interrupt_control(
    struct pci_dev *pdev, struct interrupt_control *control)
{
    struct axi_interrupt_controller *intc = control->intc;
    writel(0, &intc->mer);              // Disable controller
    free_irq(pdev->irq, control);
}
