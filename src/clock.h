#ifndef CLOCK_H
#define CLOCK_H

#include <stdint.h>
#include <time.h>

#define NS_PER_SEC 1000000000ULL

typedef uint64_t (*clock_source_fn)(void);

/* Nanoseconds from CLOCK_MONOTONIC: arbitrary start point, never jumps For durations and dealines */
uint64_t clock_mono_ns(void);

/* Nanoseconds since 1970-01-01 UTC from CLOCK_REALTIME: can jump. Use only for timestamps */
uint64_t clock_real_ns(void);

/* Tests only: replace the monotonic source. NULL restores the real clock */
void clock_set_mono_source(clock_source_fn fn);

/* Converts a timespec to nanoseconds. No system calls */
uint64_t clock_ts_to_ns(struct timespec ts);

#endif /* clock.h */
