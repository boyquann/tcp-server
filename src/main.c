#include <stdio.h>
#include <stdlib.h>

#include "server.h"

#define MIN_PORT 1024
#define MAX_PORT 65535

int main(int argc, char *argv[]) {
	int base = 10;
	long port;
	char *endptr;

	if (argc != 2) {
		fprintf(stderr, "Invalid: Input Port Number\n");
		return 1;
	}

	port = strtol(argv[1], &endptr, base);

	if (*endptr == '\0') {
		if (MIN_PORT <= port && port <= MAX_PORT) {
			return run_server((int) port);
		}

		else {
			fprintf(stderr, "Port Number %ld out of range\n", port);
			return 1;
		}
	}

	else {
		fprintf(stderr, "Invalid Port Number\n");
		return 1;
	}
}


