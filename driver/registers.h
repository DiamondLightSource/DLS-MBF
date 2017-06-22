/* Interface to register file. */

struct interrupt_control;

struct register_locking {
    struct mutex mutex;                 // Manages access to this structure
    unsigned int reference_count;       // Number of users
    struct register_context *locked_by; // Set to locking owner if locked
};

/* Called to open the file. */
int lmbf_reg_open(
    struct file *file, struct pci_dev *dev,
    struct interrupt_control *interrupts,
    struct register_locking *locking);

extern struct file_operations lmbf_reg_fops;
