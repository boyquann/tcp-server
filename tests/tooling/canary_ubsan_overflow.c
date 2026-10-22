#include <stdio.h>
#include <limits.h>

int main(int argc, char **argv)
{
	(void)argv;
	int num = INT_MAX;
	printf("Sum = %d\n", num + argc);

	return 0;
}

