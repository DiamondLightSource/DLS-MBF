/* Interface to interrupt handling. */

struct interrupt_control;
struct dma_control;

int initialise_interrupt_control(
    struct pci_dev *pdev, void __iomem *regs,
    struct dma_control *dma,
    struct interrupt_control **pcontrol);

void terminate_interrupt_control(
    struct pci_dev *pdev, struct interrupt_control *control);

/* Waits for the event mask to be non zero, returns error if interrupted. */
int wait_interrupt_events(struct interrupt_control *control);

/* Reads and consumes current event mask.  May return zero. */
char read_interrupt_events(struct interrupt_control *control);
