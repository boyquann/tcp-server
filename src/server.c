#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <netinet/in.h>
#include <string.h>

#include "server.h"
#include "connection.h"

#define BACKLOG 10

int run_server(int port) {
	int listen_fd, client_fd;
	if ((listen_fd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
		fprintf(stderr, "socket failed\n");
		return -1;
	}

	int yes = 1;

	if (setsockopt(listen_fd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes)) == -1) {
		fprintf(stderr, "setsockopt failed\n");
		close(listen_fd);
		return -1;
	}

	struct sockaddr_in addr;
	memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	addr.sin_addr.s_addr = INADDR_ANY;

	if ((bind(listen_fd, (struct sockaddr *)&addr, sizeof(addr))) == -1) {
		fprintf(stderr, "bind() failed\n");
		close(listen_fd);
		return -1;
	}

	if ((listen(listen_fd, BACKLOG)) == -1) {
		fprintf(stderr, "listen() failed\n");
		close(listen_fd);
		return -1;
	}
	
	while (1) {
		struct sockaddr_in client_addr;
		socklen_t client_len = sizeof(client_addr);

		if ((client_fd = accept(listen_fd, (struct sockaddr *)&client_addr, &client_len)) == -1) {
			fprintf(stderr, "accept() failed\n");
			close(listen_fd);
			return -1;
		}

		handle_connection(client_fd);

		close(client_fd);
	}

	return 0;
}






