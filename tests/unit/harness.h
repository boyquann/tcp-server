#ifndef HARNESS_H
#define HARNESS_H

#include <stdio.h>
#include <string.h>

typedef void (*test_fn)(void);

struct test_case {
	const char *name;
	test_fn fn;
};

#define TEST_ENTRY(func) { .name = #func, .fn = func }

static int harness_failed_flag;

#define HARNESS_FAIL(...)							\
	do {									\
		fprintf(stderr, "\t%s:%d:\t", __FILE__, __LINE__);		\
		fprintf(stderr, __VA_ARGS__);					\
		fputc('\n', stderr);						\
		harness_failed_flag = 1;					\
		return;								\	
	} while(0)

#define ASSERT_TRUE(expr)							\
	do {									\
		if (!(expr))							\
			HARNESS_FAIL("ASSERT_TRUE(%s)", #expr);			\
	} while (0)

#define ASSERT_EQ_INT(a, b)							\
	do {									\
		long long h_a_ = (long long)(a);				\
		long long h_b_ = (long long)(b);				\
		if (h_a_ != h_b_)						\
	       		HARNESS_FAIL("ASSERT_EQ_INT(%s, %s): %lld != %lld", 	\
			#a, #b, h_a_, h_b_);					\
	} while(0)

#define ASSERT_STR_EQ(a, b)							\
	do {									\
		const char *h_a_ = (a);						\
		const char *h_b_ = (b);						\
		if (strcmp(h_a_, h_b_) != 0)					\
			HARNESS_FAIL("ASSERT_STR_EQ(%s, %s): \"%s\" != \"%s\"", \
                         #a, #b, h_a_, h_b_);					\
	} while (0)

static inline int harness_run(const struct test_case *tests, size_t n) {
	size_t failures = 0;

	for (size_t i = 0; i < n; i++) {
		fprintf(stderr, "RUN %s\n", tests[i].name);
		harness_failed_flag = 0;
		(*tests[i].fn)();

		if (harness_failed_flag) {
			failures++;
			fprintf(stderr, "FAIL %s\n", tests[i].name);
		} else{
			fprintf(stderr, "OK %s\n", tests[i].name);
		}
	}
	fprintf(stderr, "%zu/%zu passed\n", n - failures, n);
	return failures == 0 ? 0 : 1;
}

#endif

