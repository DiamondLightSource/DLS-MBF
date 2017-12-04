/* Socket server core.  Maintains listening socket. */

#include <stdbool.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdarg.h>
#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <pthread.h>

#include "error.h"
#include "buffered_file.h"
#include "socket_command.h"
#include "parse.h"

#include "socket_server.h"


/* We have socket timeout on sending to avoid blocking for too long. */
#define TRANSMIT_TIMEOUT    10



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Connection management. */


struct connection {
    int sock;                       // Connected socket
    char name[64];                  // Name of connected client
    struct buffered_file *file;     // Buffered access to socket
};


static struct connection *create_connection(
    int sock, struct sockaddr_in *client)
{
    struct connection *connection = malloc(sizeof(struct connection));
    *connection = (struct connection) {
        .sock = sock,
        .file = create_buffered_file(sock, 4096, 4096),
    };

    uint8_t *ip = (uint8_t *) &client->sin_addr.s_addr;
    sprintf(connection->name, "%u.%u.%u.%u:%u",
        ip[0], ip[1], ip[2], ip[3], ntohs(client->sin_port));

    log_message("Client %s connected", connection->name);
    return connection;
}


static void report_error(
    struct connection *connection,
    error__t error, const char *command, bool raw_mode)
{
    log_message("Client %s error: %s", connection->name, error_format(error));
    if (!raw_mode)
        write_formatted_string(connection->file, "%s\n", error_format(error));
    error_discard(error);
}


static void delete_connection(struct connection *connection)
{
    error__t error = destroy_buffered_file(connection->file);
    close(connection->sock);

    ERROR_REPORT(error, "Client %s error", connection->name);
    log_message("Client %s disconnected", connection->name);
    free(connection);
}


static void *process_connection(void *context)
{
    struct connection *connection = context;
    struct buffered_file *file = connection->file;

    char line[256];
    while (read_line(file, line, sizeof(line), true))
    {
        log_message("Client %s command: \"%s\"", connection->name, line);

        const char *command = line;
        bool raw_mode = read_char(&command, 'R');
        error__t error;
        switch (*command)
        {
            case 'M':
                error = process_memory_command(file, raw_mode, ++command);
                break;
            case 'D':
                error = process_detector_command(file, raw_mode, ++command);
                break;
            case '\0':
                error = FAIL_("Missing command");
                break;
            default:
                error = FAIL_("Unknown command: '%c'", *command);
                break;
        }

        if (error)
        {
            report_error(connection, error, line, raw_mode);
            if (raw_mode)
                break;
        }
    }

    delete_connection(connection);
    return NULL;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Startup and shutdown. */

static int listen_socket = -1;
static pthread_t server_thread_id = 0;
/* We just check this flag on server shutdown to suppress error report after
 * calling shutdown. */
static volatile bool server_shutdown = false;


/* Main action of server: listens for connections and creates a thread for each
 * new session. */
static void *run_server(void *context)
{
    /* Note that we need to create the spawned threads with DETACHED attribute,
     * otherwise we accumlate internal joinable state information and eventually
     * run out of resources. */
    pthread_attr_t attr;
    ASSERT_PTHREAD(pthread_attr_init(&attr));
    ASSERT_PTHREAD(pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED));

    error__t error = ERROR_OK;
    do {
        int scon;
        struct sockaddr_in client;
        socklen_t client_len = sizeof(client);
        struct connection *connection;
        pthread_t thread;

        error =
            TEST_IO(scon = accept(listen_socket, &client, &client_len))  ?:
            DO(connection = create_connection(scon, &client))  ?:
            TEST_PTHREAD(pthread_create(
                &thread, &attr, process_connection, connection));
    } while (!error);

    if (error  &&  errno == EINVAL  &&  server_shutdown)
        /* Our normal exit reason is triggered by shutdown(listen_socket) which
         * triggers an EINVAL response, so we ignore this here. */
        error_discard(error);
    else
        ERROR_REPORT(error, "Server unexpectedly failed");
    return NULL;
}


/* Creates listening socket on the given port. */
error__t initialise_socket_server(unsigned int port)
{
    struct sockaddr_in sin = {
        .sin_family = AF_INET,
        .sin_addr.s_addr = INADDR_ANY,
        .sin_port = htons((uint16_t) port)
    };
    return
        TEST_IO(listen_socket = socket(AF_INET, SOCK_STREAM, 0))  ?:
        TEST_IO_(
            bind(listen_socket, (struct sockaddr *) &sin, sizeof(sin)),
            "Unable to bind to server socket")  ?:
        TEST_IO(listen(listen_socket, 5))  ?:
        TEST_PTHREAD(
            pthread_create(&server_thread_id, NULL, run_server, NULL));
}


/* Note that this must not be called until after socket_server() has stopped
 * running. */
void terminate_socket_server(void)
{
    if (server_thread_id)
    {
        /* If we managed to start the server thread then force it to shut down
         * and wait for termination before closing everything. */
        server_shutdown = true;
        shutdown(listen_socket, SHUT_RDWR);
        printf("Waiting for socket server\n");
        pthread_join(server_thread_id, NULL);
        close(listen_socket);
    }
}
