/* Socket support for Matlab C extensions. */


/* Some simple error handling macros.  They all call mexErrMsgIdAndTxt() which
 * does not return, instead either uses longjmp or a C++ exception. */
#define FAIL_(id, error...) \
    mexErrMsgIdAndTxt("lmbf_memory_mex:" id, error)
#define FAIL() \
    FAIL_("unexpected", "Unexpected error")
#define TEST_OK_(test, id, error...) \
    do if (!(test)) \
        FAIL_(id, error); \
    while (0)
#define TEST_IO_(test, id, error...) \
    TEST_OK_((test) != -1, id, error)
#define TEST_IO(test)   TEST_IO_(test, "unexpected", "Unexpected error")


/* Connects to socket server, if possible, returning connected socket if
 * successful.  If this function returns the caller MUST close the returned
 * socket handle before returning control to matlab. */
int connect_server(const char *hostname, int port);

/* Sends command to server and closes write side of socket so that we have
 * requested a complete transaction. */
void send_command(int sock, const char *format, ...);

/* Fills buffer from socket (or fails) and returns the number of samples
 * actually read.  The parameters behave as follows:
 *
 *  sample_size
 *      Size of a single sample in the buffer, used to compute number of bytes
 *      actually read from the socket.
 *  buffer_samples
 *      Number of samples that will fit in the buffer.
 *  samples
 *      Number of samples requested, can be larger than buffer_samples.
 *
 * The result is no greater than samples or buffer_samples.*/
int fill_buffer(
    int sock, void *buffer, int sample_size, int buffer_samples, int samples);
