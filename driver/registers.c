/* This provides memory mapped access to the registers in BAR0 and a stream of
 * events provided through interrupts. */

#include <linux/kernel.h>
#include <linux/slab.h>
#include <linux/uaccess.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/pci.h>
#include <linux/poll.h>

#include "error.h"
#include "amc525_lmbf_device.h"
#include "interrupts.h"
#include "registers.h"


struct register_context {
    unsigned long base_page;
    size_t length;
    struct interrupt_control *interrupts;
};


int lmbf_reg_open(
    struct file *file, struct pci_dev *dev,
    struct interrupt_control *interrupts)
{
    int rc = 0;
    struct register_context *context =
        kmalloc(sizeof(struct register_context), GFP_KERNEL);
    TEST_PTR(context, rc, no_context, "Unable to allocate register context");

    *context = (struct register_context) {
        .base_page = pci_resource_start(dev, 0) >> PAGE_SHIFT,
        .length = pci_resource_len(dev, 0),
        .interrupts = interrupts,
    };

    file->private_data = context;
    return 0;

no_context:
    return rc;
}


static int lmbf_reg_release(struct inode *inode, struct file *file)
{
    kfree(file->private_data);
    return 0;
}


static int lmbf_reg_mmap(struct file *file, struct vm_area_struct *vma)
{
    struct register_context *context = file->private_data;

    size_t size = vma->vm_end - vma->vm_start;
    unsigned long end = (vma->vm_pgoff << PAGE_SHIFT) + size;
    if (end > context->length)
    {
        printk(KERN_WARNING DEVICE_NAME " map area out of range\n");
        return -EINVAL;
    }

    /* Good advice and examples on using this function here:
     *  http://www.makelinux.net/ldd3/chp-15-sect-2
     * Also see drivers/char/mem.c in kernel sources for guidelines. */
    return io_remap_pfn_range(
        vma, vma->vm_start, context->base_page + vma->vm_pgoff, size,
        pgprot_noncached(vma->vm_page_prot));
}


static long lmbf_reg_ioctl(
    struct file *file, unsigned int cmd, unsigned long arg)
{
    struct register_context *context = file->private_data;
    switch (cmd)
    {
        case LMBF_MAP_SIZE:
            return context->length;
        default:
            return -EINVAL;
    }
}


/* This will return one byte with the next available event mask. */
static ssize_t lmbf_reg_read(
    struct file *file, char __user *buf, size_t count, loff_t *f_pos)
{
    struct register_context *context = file->private_data;

    /* In non blocking mode if we're not ready say so. */
    bool no_wait = file->f_flags & O_NONBLOCK;
    if (no_wait  &&  !interrupt_events_ready(context->interrupts))
        return -EAGAIN;

    char events;
    int rc = read_interrupt_events(context->interrupts, no_wait, &events);
    if (rc < 0)
        return rc;
    else if (copy_to_user(buf, &events, 1) > 0)
        return -EFAULT;
    else if (events == 0)
        /* This can happen if we're fighting with a concurrent reader and
         * O_NONBLOCK was set. */
        return -EAGAIN;
    else
        return 1;
}


static unsigned int lmbf_reg_poll(
    struct file *file, struct poll_table_struct *poll)
{
    struct register_context *context = file->private_data;

    poll_wait(file, interrupts_wait_queue(context->interrupts), poll);
    if (interrupt_events_ready(context->interrupts))
        return POLLIN | POLLRDNORM;
    else
        return 0;
}


struct file_operations lmbf_reg_fops = {
    .owner = THIS_MODULE,
    .release = lmbf_reg_release,
    .unlocked_ioctl = lmbf_reg_ioctl,
    .mmap = lmbf_reg_mmap,
    .read = lmbf_reg_read,
    .poll = lmbf_reg_poll,
};