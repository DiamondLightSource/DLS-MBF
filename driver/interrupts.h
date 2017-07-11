/* Interface to interrupt handling. */

struct interrupt_control;
struct dma_control;

int initialise_interrupt_control(
    struct pci_dev *pdev, void __iomem *regs,
    struct dma_control *dma,
    struct interrupt_control **pcontrol);

void terminate_interrupt_control(
    struct pci_dev *pdev, struct interrupt_control *control);

/* Blocks until non zero event mask can be returned. */
int read_interrupt_events(
    struct interrupt_control *control, bool no_wait, uint32_t *events);

/* Checks if a non zero event mask is available to read. */
bool interrupt_events_ready(struct interrupt_control *control);

/* Returns wait queue for interrupt status updates. */
wait_queue_head_t *interrupts_wait_queue(struct interrupt_control *control);
