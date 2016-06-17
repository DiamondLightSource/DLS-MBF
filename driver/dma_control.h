/* Interface to DMA engine. */

/* This interface provides access to both areas of DRAM on the FPGA. */

struct dma_control;

/* Initialises DMA control, returns structure used for access. */
int initialise_dma_control(
    struct pci_dev *pdev, int dma_block_shift, struct dma_control **pdma);

void terminate_dma_control(struct dma_control *dma);


/* This is called to read the specified block from FPGA memory into the DMA
 * buffer which is returned.  This buffer *must* be released when finished with
 * so that other readers can proceed. */
void *read_dma_memory(struct dma_control *dma, size_t start, size_t length);

/* Must be called after read_dma_memory() to release access to memory. */
void release_dma_memory(struct dma_control *dma);
