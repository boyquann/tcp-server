#include <stdio.h>
#include <stdlib.h>

int main(void)
{
	int *p = malloc(1 * sizeof(*p));

	if (p == NULL) {
		return 2;
	}

	*p = 1;

	free(p);

	int val = *p;

	return val;
}
