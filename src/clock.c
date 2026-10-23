#include <stdlib.h>
#include <time.h>

#include "clock.h"

uint64_t clock_ts_to_ns(struct timespec ts)
{
	return (uint64_t)ts.tv_sec * NS_PER_SEC + (uint64_t)ts.tv_nsec;
}

/* Monotonic Clock */
static uint64_t kernel_mono_ns(void)
{
	struct timespec ts;

	if (clock_gettime(CLOCK_MONOTONIC, &ts) == -1) {
		abort();
	}

	return clock_ts_to_ns(ts);
}

static clock_source_fn mono_source = kernel_mono_ns;

/* Return Monotonic Source Time Installed */
uint64_t clock_mono_ns(void) 
{
	return mono_source();
}

/* Wall Clock */
uint64_t clock_real_ns(void)
{
	struct timespec ts;

	if (clock_gettime(CLOCK_REALTIME, &ts) == -1) {
		abort();
	}

	return clock_ts_to_ns(ts);
}

/* Switch Monotonic Source */
void clock_set_mono_source(clock_source_fn fn)
{
	if (fn == NULL) {
		mono_source = kernel_mono_ns;
	}
	else {
		mono_source = fn;
	}
}
