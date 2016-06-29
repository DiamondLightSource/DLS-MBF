/* Interface to interrupt handling. */

struct interrupt_control;
struct dma_control;

int initialise_interrupt_control(
    struct pci_dev *pdev, void __iomem *regs,
    struct dma_control *dma,
    struct interrupt_control **pcontrol);

void terminate_interrupt_control(struct interrupt_control *control);
