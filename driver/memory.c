/* Support for DMA access via memory device. */

#include <linux/kernel.h>
#include <linux/slab.h>
#include <linux/uaccess.h>
#include <linux/fs.h>

#include "error.h"
#include "dma_control.h"

#include "memory.h"


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Memory device. */

/* This provides read access to the DRAM via the DMA controller with registers
 * in BAR2. */


struct memory_context {
    struct dma_control *dma;        // DMA controller
    size_t base;
    size_t length;
};


int lmbf_dma_open(
    struct file *file, struct dma_control *dma, size_t base, size_t length)
{
    int rc = 0;
    struct memory_context *context =
        kmalloc(sizeof(struct memory_context), GFP_KERNEL);
    TEST_PTR(context, rc, no_context, "Unable to allocate DMA context");

    *context = (struct memory_context) {
        .dma = dma,
        .base = base,
        .length = length,
    };

    file->private_data = context;
    return 0;

no_context:
    return rc;
}


static int lmbf_dma_release(struct inode *inode, struct file *file)
{
    kfree(file->private_data);
    return 0;
}


static ssize_t lmbf_dma_read(
    struct file *file, char __user *buf, size_t count, loff_t *f_pos)
{
    struct memory_context *context = file->private_data;

    /* Constrain read to valid region. */
    loff_t offset = *f_pos;
    if (offset >= context->length)
        return -EFAULT;

    /* Clip read to end of memory. */
    if (count > context->length - offset)
        count = context->length - offset;

    /* Read the data, transfer it to user space, release. */
    void *read_data = read_dma_memory(
        context->dma, context->base + offset, &count);
    count -= copy_to_user(buf, read_data, count);
    release_dma_memory(context->dma);

    *f_pos += count;
    if (count == 0)
        /* Looks like copy_to_user didn't copy anything. */
        return -EFAULT;
    else
        return count;
}


static loff_t lmbf_dma_llseek(struct file *file, loff_t f_pos, int whence)
{
    struct memory_context *context = file->private_data;
    return generic_file_llseek_size(
        file, f_pos, whence, context->length, context->length);
}


struct file_operations lmbf_dma_fops = {
    .owner = THIS_MODULE,
    .release = lmbf_dma_release,
    .read = lmbf_dma_read,
    .llseek = lmbf_dma_llseek,
};
