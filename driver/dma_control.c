/* Implements access to memory via dma. */

#include <linux/pci.h>
#include <linux/delay.h>
#include <linux/module.h>

#include "error.h"
#include "debug.h"

#include "dma_control.h"


#define DMA_BLOCK_SHIFT     20  // Default DMA block size as power of 2

static int dma_block_shift = DMA_BLOCK_SHIFT;
module_param(dma_block_shift, int, S_IRUGO);


/* All DMA transfers must occur on a 32-byte alignment, I guess this is the
 * 256-bit transfer size.  Alas, if this rule is violated then the DMA engine
 * simply locks up without reporting an error. */
#define DMA_ALIGNMENT       32
/* The DMA transfer count is limited to 23 bits, so the maximum transfer size is
 * 2^23-1 = 8388607 bytes, and we align the limit. */
#define MAX_DMA_TRANSFER    (((1 << 23) - 1) & ~(DMA_ALIGNMENT - 1))


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


/* Xilinx AXI DMA Controller, as defined in Xilinx PG034 documentation. */
struct axi_dma_controller {
    uint32_t cdmacr;            // 00 CDMA control
    uint32_t cdmasr;            // 04 CDMA status
    uint32_t curdesc_pntr;      // 08 (Not used, for scatter gather)
    uint32_t curdesc_pntr_msb;  // 0C (ditto)
    uint32_t taildesc_pntr;     // 10 (ditto)
    uint32_t taildesc_pntr_msb; // 14 (ditto)
    uint32_t sa;                // 18 Source address lower 32 bits
    uint32_t sa_msb;            // 1C Source address, upper 32 bits
    uint32_t da;                // 20 Destination address, lower 32 bits
    uint32_t da_msb;            // 24 Destination address, upper 32 bits
    uint32_t btt;               // 28 Bytes to transfer, writing triggers DMA
};


/* Control bits. */
#define CDMACR_Err_IrqEn    (1 << 14)   // Enable interrupt on error
#define CDMACR_IrqEn        (1 << 12)   // Enable completion interrupt
#define CDMACR_Reset        (1 << 2)    // Force soft reset of controller

/* Status bits. */
#define CDMASR_Err_Irq      (1 << 14)   // DMA error event seen
#define CDMASR_IOC_Irq      (1 << 12)   // DMA completion event seen
#define CDMASR_DMADecErr    (1 << 6)    // Address decode error seen
#define CDMASR_DMASlvErr    (1 << 5)    // Slave response error seen
#define CDMASR_DMAIntErr    (1 << 4)    // DMA internal error seen
#define CDMASR_Idle         (1 << 1)    // Last command completed


struct dma_control {
    /* Parent device. */
    struct pci_dev *pdev;

    /* BAR2 memory region for DMA controller. */
    struct axi_dma_controller __iomem *regs;

    /* Memory region for DMA. */
    int buffer_shift;       // log2(buffer_size)
    size_t buffer_size;     // Buffer size in bytes, equal to 1<<buffer_shift
    void *buffer;           // DMA transfer buffer
    dma_addr_t buffer_dma;  // Associated DMA address

    /* Mutex for exclusive access to DMA engine. */
    struct mutex mutex;

    /* Completion for DMA transfer. */
    struct completion dma_done;
};


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* DMA. */


static void reset_dma_controller(struct dma_control *dma)
{
    writel(CDMACR_Reset, &dma->regs->cdmacr);

    /* In principle we should wait for the reset to complete, though it doesn't
     * actually seem to take an observable time normally.  We use a deadline
     * just in case something goes wrong so we don't deadlock. */
    unsigned long deadline = jiffies + 2;
    int count = 0;
    while (readl(&dma->regs->cdmacr) & CDMACR_Reset  &&
           time_before(jiffies, deadline))
        count += 1;

    /* Now restore the default working state. */
    writel(0x00008000, &dma->regs->sa_msb);
    writel(CDMACR_IrqEn | CDMACR_Err_IrqEn, &dma->regs->cdmacr);
}


static void maybe_reset_dma(struct dma_control *dma)
{
    uint32_t status = readl(&dma->regs->cdmasr);
    bool error =
        status & (CDMASR_DMADecErr | CDMASR_DMASlvErr | CDMASR_DMAIntErr);
    bool idle = status & CDMASR_Idle;
    if (error || !idle)
    {
        printk(KERN_INFO "Forcing reset of DMA controller (status = %08x)\n",
            status);
        reset_dma_controller(dma);
    }
    reinit_completion(&dma->dma_done);
}


void dma_interrupt(struct dma_control *dma)
{
    uint32_t cdmasr = readl(&dma->regs->cdmasr);
    writel(cdmasr, &dma->regs->cdmasr);

    complete(&dma->dma_done);
}


ssize_t read_dma_memory(
    struct dma_control *dma, size_t start, size_t count, void **buffer)
{
    /* Adjust the dma start and byte count to be multiples of the alignment so
     * that we don't upset the DMA engine. */
    size_t align_mask_low = DMA_ALIGNMENT - 1;
    size_t align_mask_high = ~align_mask_low;
    size_t dma_start = start & align_mask_high;
    size_t start_offset = start & align_mask_low;
    /* For the count we have to add in the starting offset we've missed and
     * ensure that the entire transfer is rounded up. */
    size_t dma_count =
        (start_offset + count + align_mask_low) & align_mask_high;

    /* Ensure we only try to read as much as will fit in our buffer. */
    size_t max_count = dma->buffer_size < MAX_DMA_TRANSFER ?
        dma->buffer_size : MAX_DMA_TRANSFER;
    if (dma_count > max_count)
    {
        dma_count = max_count;
        count = dma_count - start_offset;
    }

    mutex_lock(&dma->mutex);
    *buffer = dma->buffer + start_offset;

    /* Hand the buffer over to the DMA engine. */
    pci_dma_sync_single_for_device(
        dma->pdev, dma->buffer_dma, dma->buffer_size,  DMA_FROM_DEVICE);

    /* Reset the DMA engine if necessary. */
    maybe_reset_dma(dma);

    /* Configure the engine for transfer. */
    writel((uint32_t) dma_start, &dma->regs->sa);
    writel((uint32_t) dma->buffer_dma, &dma->regs->da);
    writel((uint32_t) (dma->buffer_dma >> 32), &dma->regs->da_msb);
    /* Ensure we don't request an under sized buffer. */
    writel(dma_count, &dma->regs->btt);

    /* Wait for transfer to complete.  If we're killed, unlock and bail.  Note
     * that this call is only killable (kill -9) and not interruptible because
     * if the DMA engine does fail to complete then we have a bit of a problem
     * anyway, and if this completion were to be interrupted normally there
     * would be a hazard from the residual DMA in progress. */
    ssize_t rc = wait_for_completion_killable(&dma->dma_done);
    TEST_RC(rc, killed, "DMA transfer killed");

    /* Restore the buffer to CPU access (really just flushes associated cache
     * entries). */
    pci_dma_sync_single_for_cpu(
        dma->pdev, dma->buffer_dma, dma->buffer_size,  DMA_FROM_DEVICE);

    return count;

killed:
    mutex_unlock(&dma->mutex);
    return rc;
}


void release_dma_memory(struct dma_control *dma)
{
    mutex_unlock(&dma->mutex);
}


size_t dma_buffer_size(struct dma_control *dma)
{
    return dma->buffer_size;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Initialisation and shutdown. */


int initialise_dma_control(
    struct pci_dev *pdev, void __iomem *regs, struct dma_control **pdma)
{
    int rc = 0;
    TEST_OK(dma_block_shift >= PAGE_SHIFT, rc = -EINVAL, no_memory,
        "Invalid DMA buffer size");

    /* Create and return DMA control structure. */
    struct dma_control *dma = kmalloc(sizeof(struct dma_control), GFP_KERNEL);
    TEST_PTR(dma, rc, no_memory, "Unable to allocate DMA control");
    *pdma = dma;
    dma->pdev = pdev;
    dma->regs = regs;

    /* Allocate DMA buffer area. */
    dma->buffer_shift = dma_block_shift;
    dma->buffer_size = 1 << dma_block_shift;
    dma->buffer = (void *) __get_free_pages(
        GFP_KERNEL, dma->buffer_shift - PAGE_SHIFT);
    TEST_PTR(dma->buffer, rc, no_buffer, "Unable to allocate DMA buffer");

    /* Get the associated DMA address for the buffer. */
    dma->buffer_dma = pci_map_single(
        pdev, dma->buffer, dma->buffer_size, DMA_FROM_DEVICE);
    TEST_OK(!pci_dma_mapping_error(pdev, dma->buffer_dma),
        rc = -EIO, no_dma_map, "Unable to map DMA buffer");

    /* Final initialisation, now ready to run. */
    mutex_init(&dma->mutex);
    init_completion(&dma->dma_done);

    reset_dma_controller(dma);

    return 0;


    pci_unmap_single(pdev, dma->buffer_dma, dma->buffer_size, DMA_FROM_DEVICE);
no_dma_map:
    free_pages((unsigned long) dma->buffer, dma->buffer_shift - PAGE_SHIFT);
no_buffer:
    kfree(dma);
no_memory:
    return rc;
}


void terminate_dma_control(struct dma_control *dma)
{
    pci_unmap_single(
        dma->pdev, dma->buffer_dma, dma->buffer_size, DMA_FROM_DEVICE);
    free_pages((unsigned long) dma->buffer, dma->buffer_shift - PAGE_SHIFT);
    kfree(dma);
}
