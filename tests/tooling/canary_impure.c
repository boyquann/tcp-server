#include <unistd.h>

void impure(void);

void impure(void)
{
	(void)write(1, "x", 1);
}
