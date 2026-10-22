#include <stdlib.h>

int main(int argc, char **argv) 
{
	(void)argv;
	int *p = malloc(4 * sizeof(*p));

	if (p == NULL) {
		return 2;
	}

	p[argc + 3] = 1;
	free(p);

	return 0;
}
