#include <stdio.h>
#include <unistd.h>
#include "connection.h"

#define MAX_BUFFER_SIZE 4096

int handle_connection(int client_fd) {
	char buffer[MAX_BUFFER_SIZE];

	for(; ;) {
		int read_status = read(client_fd, buffer, MAX_BUFFER_SIZE);

		if (read_status == -1) {
			fprintf(stderr, "read() failed\n");
			return -1;
		}

		else if (read_status == 0) {
			printf("Connection closed\n");
			return 0;
		}

		int write_status = write(client_fd, buffer, read_status);

		if (write_status == -1) {
			fprintf(stderr, "write() failed\n");
			return -1;
		}

		else if (write_status < read_status) {
			while (write_status < read_status) {
				int remainder = read_status - write_status;
				int new_write_status = write(client_fd, buffer + write_status, remainder);

				if (new_write_status == -1) {
					fprintf(stderr, "write() failed\n");
					return -1;
				}

				write_status += new_write_status;
			}
		}
	}
}

	


