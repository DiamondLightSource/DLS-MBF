/* Header file for use from userspace. */

/* Although our ioctls don't transfer any data, use the direction hint anyway:
 * this helps valgrind which otherwise complains about missing size hints, and
 * it doesn't seem to mind the zero size code. */
#define MBF_IOCTL(n)        _IOC(_IOC_WRITE, 'L', n, 0)

/* Returns size of register area as unsigned 32-bit integer. */
#define MBF_MAP_SIZE        MBF_IOCTL(0)

/* Locks and unlocks access to register area for exclusive access by caller. */
#define MBF_REG_LOCK        MBF_IOCTL(2)
#define MBF_REG_UNLOCK      MBF_IOCTL(3)

/* Returns size of DMA buffer. */
#define MBF_BUF_SIZE        MBF_IOCTL(1)
