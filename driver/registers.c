/* This provides memory mapped access to the registers in BAR0 and a stream of
 * events provided through interrupts. */

#include <linux/kernel.h>
#include <linux/slab.h>
#include <linux/uaccess.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/pci.h>

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

    int rc = wait_interrupt_events(context->interrupts);
    if (rc < 0)
        return rc;

    char events = read_interrupt_events(context->interrupts);
    if (copy_to_user(buf, &events, 1) == 0)
        return 1;
    else
        return -EFAULT;
}


struct file_operations lmbf_reg_fops = {
    .owner = THIS_MODULE,
    .release = lmbf_reg_release,
    .unlocked_ioctl = lmbf_reg_ioctl,
    .mmap = lmbf_reg_mmap,
    .read = lmbf_reg_read,
};
