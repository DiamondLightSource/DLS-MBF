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
#include "amc525_mbf_core.h"
#include "amc525_mbf_device.h"
#include "dma_control.h"
#include "interrupts.h"
#include "registers.h"
#include "memory.h"
#include "debug.h"

#define _S(x)   #x
#define S(x)    _S(x)

MODULE_AUTHOR("Michael Abbott, Diamond Light Source Ltd.");
MODULE_DESCRIPTION("Driver for MBF AMC525 FPGA MTCA card");
MODULE_LICENSE("GPL");
MODULE_VERSION(S(VERSION));


/* Card identification. */
#define XILINX_VID      0x10EE
#define AMC525_DID      0x7038
#define AMC525_SID      0x0007


/* Physical layout in DDR address space of the two memory areas. */
#define DDR0_BASE       0
#define DDR0_LENGTH     0x80000000      // 2GB
#define DDR1_BASE       0x80000000
#define DDR1_LENGTH     0x08000000      // 128MB


/* Expected length of BAR2. */
#define BAR2_LENGTH     16384           // 4 separate IO pages


/* Address offsets into BAR2. */
#define CDMA_OFFSET     0x0000          // DMA controller       (PG034)
#define INTC_OFFSET     0x1000          // Interrupt controller (PG099)



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Structures. */


/* All the driver specific state for a card is in this structure. */
struct amc525_mbf {
    struct cdev cdev;
    struct pci_dev *dev;
    int board;              // Index number for this board
    int major;              // Major device number
    int minor;              // Associated minor number

    /* Reference counting and completion to cope with lifetime management during
     * FPGA reload events. */
    atomic_t refcount;              // Number of file handles open (+1)
    struct completion completion;   // Used to handshake final device close

    /* BAR2 memory mapped region, used for driver control. */
    void __iomem *ctrl_memory;

    /* Locking control for exclusive access to ctrl_memory. */
    struct register_locking locking;

    /* DMA controller. */
    struct dma_control *dma;

    /* Interrupt controller. */
    struct interrupt_control *interrupts;
};


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Basic file operations. */

static struct {
    const char *name;
    struct file_operations *fops;
} fops_info[] = {
    { .name = "reg",    .fops = &mbf_reg_fops, },
    { .name = "ddr0",   .fops = &mbf_dma_fops, },
    { .name = "ddr1",   .fops = &mbf_dma_fops, },
};

#define MINORS_PER_BOARD    ARRAY_SIZE(fops_info)

#define MINOR_REG       0
#define MINOR_DDR0      1
#define MINOR_DDR1      2


/* This must be called whenever any MBF file handle is released. */
void amc525_mbf_release(struct inode *inode)
{
    struct cdev *cdev = inode->i_cdev;
    struct amc525_mbf *mbf = container_of(cdev, struct amc525_mbf, cdev);
    if (atomic_dec_and_test(&mbf->refcount))
        complete(&mbf->completion);
}


static int amc525_mbf_open(struct inode *inode, struct file *file)
{
    /* Recover our private data: the i_cdev lives inside our private structure,
     * so we'll copy the appropriate link to our file structure. */
    struct cdev *cdev = inode->i_cdev;
    struct amc525_mbf *mbf = container_of(cdev, struct amc525_mbf, cdev);

    /* Check that the file handle is still live. */
    if (!atomic_inc_not_zero(&mbf->refcount))
        return -ENXIO;

    /* Replace the file's f_ops with our own and perform any device specific
     * initialisation. */
    int minor_index = iminor(inode) - mbf->minor;
    file->f_op = fops_info[minor_index].fops;
    int rc = -EINVAL;
    switch (minor_index)
    {
        case MINOR_REG:
            rc = mbf_reg_open(file, mbf->dev, mbf->interrupts, &mbf->locking);
            break;
        case MINOR_DDR0:
            rc = mbf_dma_open(file, mbf->dma, DDR0_BASE, DDR0_LENGTH);
            break;
        case MINOR_DDR1:
            rc = mbf_dma_open(file, mbf->dma, DDR1_BASE, DDR1_LENGTH);
            break;
    }

    if (rc < 0)
        amc525_mbf_release(inode);
    return rc;
}


static struct file_operations base_fops = {
    .owner = THIS_MODULE,
    .open = amc525_mbf_open,
};


static int create_device_nodes(
    struct pci_dev *pdev, struct amc525_mbf *mbf, struct class *device_class)
{
    int major = mbf->major;
    int minor = mbf->minor;

    cdev_init(&mbf->cdev, &base_fops);
    mbf->cdev.owner = THIS_MODULE;
    int rc = cdev_add(&mbf->cdev, MKDEV(major, minor), MINORS_PER_BOARD);
    TEST_RC(rc, no_cdev, "Unable to add device");

    for (int i = 0; i < MINORS_PER_BOARD; i ++)
        device_create(
            device_class, &pdev->dev, MKDEV(major, minor + i), NULL,
            "%s.%d.%s", DEVICE_NAME, mbf->board, fops_info[i].name);
    return 0;

no_cdev:
    return rc;
}


static void destroy_device_nodes(
    struct amc525_mbf *mbf, struct class *device_class)
{
    int major = mbf->major;
    int minor = mbf->minor;

    for (int i = 0; i < MINORS_PER_BOARD; i ++)
        device_destroy(device_class, MKDEV(major, minor + i));
    cdev_del(&mbf->cdev);
}



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
    TEST_RC(rc, no_device, "Unable to enable AMC525 MBF\n");

    rc = pci_request_regions(pdev, DEVICE_NAME);
    TEST_RC(rc, no_regions, "Unable to reserve resources");

    rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
    TEST_RC(rc, no_dma_mask, "Unable to set DMA mask");

    pci_set_master(pdev);

    rc = pci_enable_msi(pdev);
    TEST_RC(rc, no_msi, "Unable to enable MSI");

    return 0;

    pci_disable_msi(pdev);
no_msi:
    pci_clear_master(pdev);
no_dma_mask:
    pci_release_regions(pdev);
no_regions:
    pci_disable_device(pdev);
no_device:
    return rc;
}


static void disable_board(struct pci_dev *pdev)
{
    pci_disable_msi(pdev);
    pci_clear_master(pdev);
    pci_release_regions(pdev);
    pci_disable_device(pdev);
}


static int initialise_board(struct pci_dev *pdev, struct amc525_mbf *mbf)
{
    int rc = 0;
    pci_set_drvdata(pdev, mbf);

    /* Map the control area bar. */
    int bar2_length = pci_resource_len(pdev, 2);
    TEST_OK(bar2_length >= BAR2_LENGTH, rc = -EINVAL, no_bar2,
        "Invalid length for bar2");
    mbf->ctrl_memory = pci_iomap(pdev, 2, BAR2_LENGTH);
    TEST_PTR(mbf->ctrl_memory, rc, no_bar2, "Unable to map control BAR");

    rc = initialise_dma_control(
        pdev, mbf->ctrl_memory + CDMA_OFFSET, &mbf->dma);
    if (rc < 0)  goto no_dma;

    rc = initialise_interrupt_control(
        pdev, mbf->ctrl_memory + INTC_OFFSET, mbf->dma,
        &mbf->interrupts);
    if (rc < 0)  goto no_irq;

    return 0;


    terminate_interrupt_control(pdev, mbf->interrupts);
no_irq:
    terminate_dma_control(mbf->dma);
no_dma:
    pci_iounmap(pdev, mbf->ctrl_memory);
no_bar2:
    return rc;
}


static void terminate_board(struct pci_dev *pdev)
{
    struct amc525_mbf *mbf = pci_get_drvdata(pdev);
    terminate_interrupt_control(pdev, mbf->interrupts);
    terminate_dma_control(mbf->dma);
    pci_iounmap(pdev, mbf->ctrl_memory);
}


/* Top level device probe method: called when AMC525 FPGA card with our firmware
 * detected. */
static int amc525_mbf_probe(
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
    struct amc525_mbf *mbf = kmalloc(sizeof(struct amc525_mbf), GFP_KERNEL);
    TEST_PTR(mbf, rc, no_memory, "Unable to allocate memory");
    *mbf = (struct amc525_mbf) {
        .dev = pdev,
        .board = board,
        .major = major,
        .minor = minor,
    };
    mutex_init(&mbf->locking.mutex);
    atomic_set(&mbf->refcount, 1);
    init_completion(&mbf->completion);

    rc = enable_board(pdev);
    if (rc < 0)     goto no_enable;

    rc = initialise_board(pdev, mbf);
    if (rc < 0)     goto no_initialise;

    rc = create_device_nodes(pdev, mbf, device_class);
    if (rc < 0)     goto no_cdev;

    return 0;


    destroy_device_nodes(mbf, device_class);
no_cdev:
    terminate_board(pdev);
no_initialise:
    disable_board(pdev);
no_enable:
    kfree(mbf);
no_memory:
    release_board(board);
no_board:
    return rc;
}


/* Waits for all open file handles to be released so that we can safely release
 * the hardware resources. */
static void wait_for_clients(struct amc525_mbf *mbf)
{
    if (atomic_dec_and_test(&mbf->refcount))
        complete(&mbf->completion);
    wait_for_completion(&mbf->completion);
}


static void amc525_mbf_remove(struct pci_dev *pdev)
{
    printk(KERN_INFO "Removing AMC525 device\n");
    struct amc525_mbf *mbf = pci_get_drvdata(pdev);

    destroy_device_nodes(mbf, device_class);
    wait_for_clients(mbf);

    terminate_board(pdev);
    disable_board(pdev);
    release_board(mbf->board);

    kfree(mbf);
}


static struct pci_device_id amc525_pci_ids[] = {
    { PCI_DEVICE_SUB(XILINX_VID, AMC525_DID, XILINX_VID, AMC525_SID) },
    { 0 }
};

MODULE_DEVICE_TABLE(pci, amc525_pci_ids);

static struct pci_driver amc525_mbf_driver = {
    .name = DEVICE_NAME,
    .id_table = amc525_pci_ids,
    .probe = amc525_mbf_probe,
    .remove = amc525_mbf_remove,
};


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Driver initialisation. */


static int __init amc525_mbf_init(void)
{
    printk(KERN_INFO "Loading AMC525 MBF module\n");
    int rc = 0;

    /* Allocate major device number and create class. */
    rc = alloc_chrdev_region(&device_major, 0, MAX_MINORS, DEVICE_NAME);
    TEST_RC(rc, no_chrdev, "Unable to allocate dev region");

    device_class = class_create(THIS_MODULE, DEVICE_NAME);
    TEST_PTR(device_class, rc, no_class, "Unable to create class");

    rc = pci_register_driver(&amc525_mbf_driver);
    TEST_RC(rc, no_driver, "Unable to register driver\n");
    printk(KERN_INFO "Registered AMC525 MBF driver\n");
    return rc;

no_driver:
    class_destroy(device_class);
no_class:
    unregister_chrdev_region(device_major, MAX_MINORS);
no_chrdev:
    return rc;
}


static void __exit amc525_mbf_exit(void)
{
    printk(KERN_INFO "Unloading AMC525 MBF module\n");
    pci_unregister_driver(&amc525_mbf_driver);
    class_destroy(device_class);
    unregister_chrdev_region(device_major, MAX_MINORS);
}

module_init(amc525_mbf_init);
module_exit(amc525_mbf_exit);
