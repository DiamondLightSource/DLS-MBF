/* Header file for use from userspace. */

/* Returns size of register area as unsigned 32-bit integer. */
#define LMBF_MAP_SIZE       _IO('L', 0)

/* Returns size of DMA buffer. */
#define LMBF_BUF_SIZE       _IO('L', 1)
