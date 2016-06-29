/* Interface to register file. */

struct interrupt_control;

/* Called to open the file. */
int lmbf_reg_open(
    struct file *file, struct pci_dev *dev,
    struct interrupt_control *interrupts);

extern struct file_operations lmbf_reg_fops;
