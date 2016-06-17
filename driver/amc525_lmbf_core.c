#include <linux/module.h>
#include <linux/version.h>
#include <linux/device.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/pci.h>
#include <linux/uaccess.h>
#include <linux/interrupt.h>
#include <linux/sched.h>
#include <linux/slab.h>
#include <linux/delay.h>

#include "error.h"
#include "amc525_lmbf_device.h"
#include "dma_control.h"


MODULE_AUTHOR("Michael Abbott, Diamond Light Source Ltd.");
MODULE_DESCRIPTION("Driver for LMBF AMC525 FPGA MTCA card");
MODULE_LICENSE("GPL");
// MODULE_VERSION(S(VERSION));
MODULE_VERSION("0");

#define XILINX_VID      0x10EE
#define AMC525_DID      0x7038


#define DMA_BLOCK_SHIFT     20  // Default DMA block size as power of 2

static int dma_block_shift = DMA_BLOCK_SHIFT;
module_param(dma_block_shift, int, S_IRUGO);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Structures. */


/* All the driver specific state for a card is in this structure. */
struct amc525_lmbf {
    struct cdev cdev;
    struct pci_dev *dev;
    int board;              // Index number for this board
    int minor;              // Associated minor number

    /* BAR0 memory mapped register region. */
    unsigned long reg_length;
    void __iomem *reg_memory;

    /* DMA controller. */
    struct dma_control *dma;
};


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Memory device. */

/* This provides read access to the DRAM via the DMA controller with registers
 * in BAR2. */


#define DDR0_BASE       0
#define DDR0_LENGTH     0x80000000      // 2GB


static ssize_t lmbf_mem_read(
    struct file *file, char __user *buf, size_t count, loff_t *f_pos)
{
    printk(KERN_INFO "mem read: %zu %llu\n", count, *f_pos);

    struct amc525_lmbf *lmbf = file->private_data;

    /* Constrain read to valid region. */
    loff_t offset = *f_pos;
    if (offset >= DDR0_LENGTH)
        return -EFAULT;

    /* Clip read to buffer size and end of memory. */
    size_t buffer_size = 1 << dma_block_shift;
    if (count > buffer_size)
        count = buffer_size;
    if (count > DDR0_LENGTH - offset)
        count = DDR0_LENGTH - offset;

    /* Read the data, transfer it to user space, release. */
    void *read_data = read_dma_memory(lmbf->dma, offset, count);
    count -= copy_to_user(buf, read_data, count);
    release_dma_memory(lmbf->dma);

    *f_pos += count;
    if (count == 0)
        /* Looks like copy_to_user didn't copy anything. */
        return -EFAULT;
    else
        return count;
}


static loff_t lmbf_mem_llseek(
    struct file *file, loff_t f_pos, int whence)
{
    printk(KERN_INFO "mem seek: %llu (%d)\n", f_pos, whence);
    return generic_file_llseek_size(
        file, f_pos, whence, DDR0_LENGTH, DDR0_LENGTH);
}


static struct file_operations lmbf_mem_fops = {
    .owner = THIS_MODULE,
    .read = lmbf_mem_read,
    .llseek = lmbf_mem_llseek,
};


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Register map device. */

/* This provides memory mapped access to the registers in BAR0. */

static int lmbf_reg_map(struct file *file, struct vm_area_struct *vma)
{
    struct amc525_lmbf *lmbf = file->private_data;

    size_t size = vma->vm_end - vma->vm_start;
    unsigned long end = (vma->vm_pgoff << PAGE_SHIFT) + size;
    if (end > lmbf->reg_length)
    {
        printk(KERN_WARNING DEVICE_NAME " map area out of range\n");
        return -EINVAL;
    }

    /* Good advice and examples on using this function here:
     *  http://www.makelinux.net/ldd3/chp-15-sect-2
     * Also see drivers/char/mem.c in kernel sources for guidelines. */
    unsigned long base_page = pci_resource_start(lmbf->dev, 0) >> PAGE_SHIFT;
    return io_remap_pfn_range(
        vma, vma->vm_start, base_page + vma->vm_pgoff, size,
        pgprot_noncached(vma->vm_page_prot));
}


static long lmbf_reg_ioctl(
    struct file *file, unsigned int cmd, unsigned long arg)
{
    struct amc525_lmbf *lmbf = file->private_data;
    switch (cmd)
    {
        case LMBF_MAP_SIZE:
            return lmbf->reg_length;
        default:
            return -EINVAL;
    }
}


static struct file_operations lmbf_reg_fops = {
    .owner = THIS_MODULE,
    .unlocked_ioctl = lmbf_reg_ioctl,
    .mmap = lmbf_reg_map,
};


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Basic file operations. */

static struct {
    const char *name;
    struct file_operations *fops;
} fops_info[] = {
    { .name = "reg",    .fops = &lmbf_reg_fops, },
    { .name = "mem",    .fops = &lmbf_mem_fops, },
};

#define MINORS_PER_BOARD    ARRAY_SIZE(fops_info)


static int amc525_lmbf_open(struct inode *inode, struct file *file)
{
    /* Recover our private data: the i_cdev lives inside our private structure,
     * so we'll copy the appropriate link to our file structure. */
    struct cdev *cdev = inode->i_cdev;
    struct amc525_lmbf *lmbf = container_of(cdev, struct amc525_lmbf, cdev);
    file->private_data = lmbf;

    /* Replace the file's f_ops with our own. */
    int minor_index = iminor(inode) - lmbf->minor;
    if (0 <= minor_index  &&  minor_index < MINORS_PER_BOARD)
    {
        file->f_op = fops_info[minor_index].fops;
        if (file->f_op->open)
            return file->f_op->open(inode, file);
        else
            return 0;
    }
    else
        /* No idea how this can happen, to be honest. */
        return -EINVAL;
}


static struct file_operations base_fops = {
    .owner = THIS_MODULE,
    .open = amc525_lmbf_open,
};



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Device initialisation. */

/* In principle there may be multiple boards installed, so we'll allow for this
 * when allocating the device nodes. */

#define MAX_BOARDS          4
#define MAX_MINORS          (MAX_BOARDS * MINORS_PER_BOARD)

static struct class *device_class;  // Device class
static dev_t device_major;          // Major device number for our device
static long device_boards;          // Bit mask of allocated boards


/* Searches for an unallocated board number. */
static int get_free_board(unsigned int *board)
{
    for (int bit = 0; bit < MAX_BOARDS; bit ++)
    {
        if (test_and_set_bit(bit, &device_boards) == 0)
        {
            *board = bit;
            return 0;
        }
    }
    printk(KERN_ERR "Unable to allocate minor for device\n");
    return -EIO;
}

static void release_board(unsigned int board)
{
    test_and_clear_bit(board, &device_boards);
}


/* Performs basic PCI device initialisation. */
static int enable_board(struct pci_dev *pdev)
{
    int rc = pci_enable_device(pdev);
    TEST_RC(rc, no_device, "Unable to enable AMC525 LMBF\n");

    rc = pci_request_regions(pdev, DEVICE_NAME);
    TEST_RC(rc, no_regions, "Unable to reserve resources");

    rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
    TEST_RC(rc, no_dma_mask, "Unable to set DMA mask");

    pci_set_master(pdev);

    return 0;

no_dma_mask:
    pci_release_regions(pdev);
no_regions:
    pci_disable_device(pdev);
no_device:
    return rc;
}


static void disable_board(struct pci_dev *pdev)
{
    pci_clear_master(pdev);
    pci_release_regions(pdev);
    pci_disable_device(pdev);
}


static int initialise_board(struct pci_dev *pdev, struct amc525_lmbf *lmbf)
{
    int rc = 0;
    pci_set_drvdata(pdev, lmbf);

    /* Map the register bar. */
    lmbf->reg_length = pci_resource_len(pdev, 0);
    lmbf->reg_memory = pci_iomap(pdev, 0, lmbf->reg_length);
    TEST_PTR(lmbf->reg_memory, rc, no_memory, "Unable to map register bar");

    rc = initialise_dma_control(pdev, dma_block_shift, &lmbf->dma);
    if (rc < 0)  goto no_dma;

    return 0;


    terminate_dma_control(lmbf->dma);
no_dma:
    pci_iounmap(pdev, lmbf->reg_memory);
no_memory:
    return rc;
}


static void terminate_board(struct pci_dev *pdev)
{
    struct amc525_lmbf *lmbf = pci_get_drvdata(pdev);

    terminate_dma_control(lmbf->dma);
    pci_iounmap(pdev, lmbf->reg_memory);
}


static int amc525_lmbf_probe(
    struct pci_dev *pdev, const struct pci_device_id *id)
{
    printk(KERN_INFO "Detected AMC525\n");
    int rc = 0;

    /* Ensure we can allocate a board number. */
    unsigned int board;
    rc = get_free_board(&board);
    TEST_RC(rc, no_board, "Unable to allocate board number\n");
    int major = MAJOR(device_major);
    int minor = board * MINORS_PER_BOARD;

    /* Allocate state for our board. */
    struct amc525_lmbf *lmbf = kmalloc(sizeof(struct amc525_lmbf), GFP_KERNEL);
    TEST_PTR(lmbf, rc, no_memory, "Unable to allocate memory");
    lmbf->dev = pdev;
    lmbf->board = board;
    lmbf->minor = minor;

    rc = enable_board(pdev);
    if (rc < 0)     goto no_enable;

    rc = initialise_board(pdev, lmbf);
    if (rc < 0)     goto no_initialise;

    cdev_init(&lmbf->cdev, &base_fops);
    lmbf->cdev.owner = THIS_MODULE;
    rc = cdev_add(&lmbf->cdev, MKDEV(major, minor), MINORS_PER_BOARD);
    TEST_RC(rc, no_cdev, "Unable to add device");

    for (int i = 0; i < MINORS_PER_BOARD; i ++)
        device_create(
            device_class, &pdev->dev, MKDEV(major, minor + i), NULL,
            "%s.%d.%s", DEVICE_NAME, board, fops_info[i].name);


//     rc = request_irq(
//         pdev->irq, fa_sniffer_isr, IRQF_SHARED, DEVICE_NAME, open);
//     TEST_RC(rc, no_irq, "Unable to request irq");

    return 0;


    cdev_del(&lmbf->cdev);
no_cdev:
    terminate_board(pdev);
no_initialise:
    disable_board(pdev);
no_enable:
    kfree(lmbf);
no_memory:
    release_board(board);
no_board:
    return rc;
}


static void amc525_lmbf_remove(struct pci_dev *pdev)
{
    printk(KERN_INFO "Removing AMC525 device\n");
    struct amc525_lmbf *lmbf = pci_get_drvdata(pdev);
    int major = MAJOR(device_major);

    for (int i = 0; i < MINORS_PER_BOARD; i ++)
        device_destroy(device_class, MKDEV(major, lmbf->minor + i));
    cdev_del(&lmbf->cdev);
    terminate_board(pdev);
    disable_board(pdev);
    kfree(lmbf);
    release_board(lmbf->board);
}


static struct pci_driver amc525_lmbf_driver = {
    .name = DEVICE_NAME,
    .id_table = (const struct pci_device_id[]) {
        { PCI_DEVICE(XILINX_VID, AMC525_DID) },
    },
    .probe = amc525_lmbf_probe,
    .remove = amc525_lmbf_remove,
};


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Driver initialisation. */


static int __init amc525_lmbf_init(void)
{
    printk(KERN_INFO "Loading AMC525 LMBF module\n");
    int rc = 0;

    /* Allocate major device number and create class. */
    rc = alloc_chrdev_region(&device_major, 0, MAX_MINORS, DEVICE_NAME);
    TEST_RC(rc, no_chrdev, "Unable to allocate dev region");

    device_class = class_create(THIS_MODULE, DEVICE_NAME);
    TEST_PTR(device_class, rc, no_class, "Unable to create class");

    rc = pci_register_driver(&amc525_lmbf_driver);
    TEST_RC(rc, no_driver, "Unable to register driver\n");
    printk(KERN_INFO "Registered AMC525 LMBF driver\n");
    return rc;

no_driver:
    class_destroy(device_class);
no_class:
    unregister_chrdev_region(device_major, MAX_MINORS);
no_chrdev:
    return rc;
}


static void __exit amc525_lmbf_exit(void)
{
    printk(KERN_INFO "Unloading AMC525 LMBF module\n");
    pci_unregister_driver(&amc525_lmbf_driver);
    class_destroy(device_class);
    unregister_chrdev_region(device_major, MAX_MINORS);
}

module_init(amc525_lmbf_init);
module_exit(amc525_lmbf_exit);
