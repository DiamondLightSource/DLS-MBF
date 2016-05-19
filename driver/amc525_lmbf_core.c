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


MODULE_AUTHOR("Michael Abbott, Diamond Light Source Ltd.");
MODULE_DESCRIPTION("Driver for LMBF AMC525 FPGA MTCA card");
MODULE_LICENSE("GPL");
// MODULE_VERSION(S(VERSION));
MODULE_VERSION("0");

#define XILINX_VID      0x10EE
#define AMC525_DID      0x7038



static int amc525_lmbf_probe(
    struct pci_dev *pdev, const struct pci_device_id *id)
{
    printk(KERN_INFO "Detected AMC525\n");
    return 0;
}


static void amc525_lmbf_remove(struct pci_dev *pdev)
{
    printk(KERN_INFO "Removing AMC525 device\n");
}


static struct pci_driver amc525_lmbf_driver = {
    .name = "amc525_lmbf",
    .id_table = (const struct pci_device_id[]) {
        { PCI_DEVICE(XILINX_VID, AMC525_DID) },
    },
    .probe = amc525_lmbf_probe,
    .remove = amc525_lmbf_remove,
};


static int __init amc525_lmbf_init(void)
{
    printk(KERN_INFO "Loading AMC525 LMBF module\n");
    int rc = 0;

    rc = pci_register_driver(&amc525_lmbf_driver);
    TEST_RC(rc, no_driver, "Unable to register driver\n");
    printk(KERN_INFO "Registered AMC525 LMBF driver\n");
    return rc;

no_driver:
    return 0;
}


static void __exit amc525_lmbf_exit(void)
{
    printk(KERN_INFO "Unloaded AMC525 LMBF module\n");
    pci_unregister_driver(&amc525_lmbf_driver);
}

module_init(amc525_lmbf_init);
module_exit(amc525_lmbf_exit);
