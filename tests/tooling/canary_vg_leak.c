#include <stdlib.h>

int main(void)
{
	int *p = malloc(1 * sizeof(*p));

	if (p == NULL) {
		return 2;
	}
	*p = 1;

	return 0;
}
