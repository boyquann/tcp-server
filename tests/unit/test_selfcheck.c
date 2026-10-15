#include "harness.h"

static void test_passes(void) {
	ASSERT_TRUE(1 == 1);
	ASSERT_EQ_INT(1 + 1, 2);
	ASSERT_STR_EQ("abc", "abc");
}


int main(void) {
	static const struct test_case tests[] = {
		TEST_ENTRY(test_passes),
	};
	return harness_run(tests, sizeof(tests) / sizeof(tests[0]));
