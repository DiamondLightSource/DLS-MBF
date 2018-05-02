/* Socket support for Matlab C extensions. */


/* Some simple error handling macros.  They all call mexErrMsgIdAndTxt() which
 * does not return, instead either uses longjmp or a C++ exception. */
#define UNEXPECTED_ERROR  "unexpected", "Unexpected error"
#define FAIL_(id, error...) \
    mexErrMsgIdAndTxt("mex_mbf:" id, error)
#define FAIL() \
    FAIL_("unexpected", "Unexpected error")
#define TEST_OK_(test, id, error...) \
    do if (!(test)) \
        FAIL_(id, error); \
    while (0)
#define TEST_OK(test)   TEST_OK_(test, "unexpected", "Unexpected error")
#define TEST_IO_(test, id, error...) \
    TEST_OK_((test) != -1, id, error)
#define TEST_IO(test)   TEST_IO_(test, "unexpected", "Unexpected error")

/* A special annoyance for error tests with a socket involved: we need to close
 * the socket before failing! */
#define TEST_SOCK_(sock, test, id, error...) \
    do if (!(test)) \
    { \
        close(sock); \
        FAIL_(id, error); \
    } while (0)
#define TEST_SOCK(sock, test) \
    TEST_SOCK_(sock, test, "unexpected", "Unexpected error")


/* Creates and returns matlab array and returns pointers to real and imaginary
 * parts.  If imags is NULL then a real array is created. */
mxArray *create_double_array(
    int rows, int cols, double **reals, double **imags);
mxArray *create_single_array(
    int rows, int cols, float **reals, float **imags);

/* Connects to socket server, if possible, returning connected socket if
 * successful.  If this function returns the caller MUST close the returned
 * socket handle before returning control to matlab. */
int connect_server(const char *hostname, int port);

/* Sends command to server and closes write side of socket so that we have
 * requested a complete transaction. */
void send_command(int sock, const char *format, ...);

/* Checks server response, raises error if the server returns error.  Expects
 * server to return single null character on success, error message on fail. */
void check_result(int sock);

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
