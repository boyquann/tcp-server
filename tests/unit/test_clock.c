#include <stdint.h>

#include "clock.h"
#include "harness.h"

#define FAKE_STEP 500ULL

static uint64_t fake_now;

static uint64_t fake_advancing(void)
{
	fake_now += FAKE_STEP;
	return fake_now;
}
static uint64_t fake_fixed(void)
{
	return 1000;
}

static void test_fake_source_used(void)
{
	clock_set_mono_source(fake_fixed);
	uint64_t got = clock_mono_ns();
	clock_set_mono_source(NULL);

	ASSERT_TRUE(got == 1000);
}

static void test_mono_never_decreases(void)
{
	clock_set_mono_source(NULL);
	uint64_t prev = clock_mono_ns();

	for (uint64_t i = 0; i < 1000; i++) {
		uint64_t new = clock_mono_ns();
		ASSERT_TRUE(new >= prev);
		prev = new;
	}
}

static void test_real_is_plausible(void)
{
	uint64_t past_ns = 1767225600 * NS_PER_SEC;
	uint64_t future_ns = 4102444800 * NS_PER_SEC;
	uint64_t new = clock_real_ns();

	ASSERT_TRUE(new > past_ns);
       	ASSERT_TRUE(new < future_ns);
}

static void test_fake_source_advances(void)
{
	fake_now = 0;
	clock_set_mono_source(fake_advancing);
	uint64_t first = clock_mono_ns();
	uint64_t second = clock_mono_ns();
	clock_set_mono_source(NULL);

	ASSERT_TRUE(first == FAKE_STEP);
	ASSERT_TRUE(second - first == FAKE_STEP);
}

static void test_null_restores_real(void)
{
	clock_set_mono_source(fake_fixed);
	clock_set_mono_source(NULL);
	uint64_t got = clock_mono_ns();

	ASSERT_TRUE(got != 1000);
}

static void test_conversion_at_second_boundary(void)
{
	struct timespec before = { .tv_sec = 1, .tv_nsec = 999999999 };
	struct timespec after = { .tv_sec = 2, .tv_nsec = 0 };

	ASSERT_TRUE(clock_ts_to_ns(before) == 1999999999);
	ASSERT_TRUE(clock_ts_to_ns(after) == 2000000000);
	ASSERT_TRUE(clock_ts_to_ns(after) > clock_ts_to_ns(before));
}

int main(void)
{
	static const struct test_case tests[] = {
		TEST_ENTRY(test_fake_source_used),
		TEST_ENTRY(test_mono_never_decreases),
		TEST_ENTRY(test_real_is_plausible),
		TEST_ENTRY(test_fake_source_advances),
		TEST_ENTRY(test_null_restores_real),
		TEST_ENTRY(test_conversion_at_second_boundary),
	}

	return harness_run(tests, sizeof(tests) / sizeof(tests[0]));
}
