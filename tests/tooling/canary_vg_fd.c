#include <stdio.h>
#include <fcntl.h>

int main(void)
{
	int fd = open("/dev/null", O_RDONLY);

	if (fd < 2) {
		return 2;
	}

	return 0;
}
