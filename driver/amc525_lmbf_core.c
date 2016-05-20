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


#define DEVICE_NAME     "amc525_lmbf"

MODULE_AUTHOR("Michael Abbott, Diamond Light Source Ltd.");
MODULE_DESCRIPTION("Driver for LMBF AMC525 FPGA MTCA card");
MODULE_LICENSE("GPL");
// MODULE_VERSION(S(VERSION));
MODULE_VERSION("0");

#define XILINX_VID      0x10EE
#define AMC525_DID      0x7038


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/* All the driver specific state for a card is in this structure. */
struct amc525_lmbf {
    struct cdev cdev;
    int board;              // Index number for this board
    int minor;              // Associated minor number
};

static struct file_operations lmbf_reg_fops = {
    .owner = THIS_MODULE,
};

static struct file_operations lmbf_mem_fops = {
    .owner = THIS_MODULE,
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
            return -EIO;
    }
    else
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

//     rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
//     pci_set_master(pdev);

    return 0;

    pci_release_regions(pdev);
no_regions:
    pci_disable_device(pdev);
no_device:
    return rc;
}


static void disable_board(struct pci_dev *pdev)
{
//     pci_clear_master(pdev);
    pci_release_regions(pdev);
    pci_disable_device(pdev);
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
    pci_set_drvdata(pdev, lmbf);
    lmbf->board = board;
    lmbf->minor = minor;

    rc = enable_board(pdev);
    if (rc < 0)     goto no_enable;

    cdev_init(&lmbf->cdev, &base_fops);
    lmbf->cdev.owner = THIS_MODULE;
    rc = cdev_add(&lmbf->cdev, MKDEV(major, minor), MINORS_PER_BOARD);
    TEST_RC(rc, no_cdev, "Unable to add device");

    for (int i = 0; i < MINORS_PER_BOARD; i ++)
        device_create(
            device_class, &pdev->dev, MKDEV(major, minor + i), NULL,
            "%s.%d.%s", DEVICE_NAME, board, fops_info[i].name);

    return 0;


    cdev_del(&lmbf->cdev);
no_cdev:
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
