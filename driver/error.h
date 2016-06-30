#define DEVICE_NAME     "amc525_lmbf"

/* If test is false then do on_error, print message and goto target. */
#define TEST_OK(test, on_error, target, message) \
    do if (unlikely(!(test))) { \
        on_error; \
        printk(KERN_ERR DEVICE_NAME ": " message "\n"); \
        goto target; \
    } while (0)

/* If rc is an error code (< 0) then print message and goto target. */
#define TEST_RC(rc, target, message) \
    TEST_OK((rc) >= 0, , target, message)

/* If ptr indicates an error then assign the associated error code to rc, print
 * message and goto target.  If ptr is in fact NULL we return -ENOMEM. */
#define TEST_PTR(ptr, rc, target, message) \
    TEST_OK(!IS_ERR_OR_NULL(ptr), rc = PTR_ERR(ptr)?:-ENOMEM, target, message)
