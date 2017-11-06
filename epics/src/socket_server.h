/* Interface to socket server. */

/* Initialises the socket server and starts it. */
error__t initialise_socket_server(unsigned int port);

/* Ensures all connections are terminated and releases any resources. */
void terminate_socket_server(void);
