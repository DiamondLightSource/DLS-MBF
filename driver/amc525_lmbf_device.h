/* Header file for use from userspace. */

/* Although our ioctls don't transfer any data, use the direction hint anyway:
 * this helps valgrind which otherwise complains about missing size hints, and
 * it doesn't seem to mind the zero size code. */
#define LMBF_IOCTL(n)       _IOC(_IOC_WRITE, 'L', n, 0)

/* Returns size of register area as unsigned 32-bit integer. */
#define LMBF_MAP_SIZE       LMBF_IOCTL(0)

/* Locks and unlocks access to register area for exclusive access by caller. */
#define LMBF_REG_LOCK       LMBF_IOCTL(2)
#define LMBF_REG_UNLOCK     LMBF_IOCTL(3)

/* Returns size of DMA buffer. */
#define LMBF_BUF_SIZE       LMBF_IOCTL(1)
