# D-0001 :LICENSE 
**Decision:** This work is under the MIT License as its purpose is to be read and reused freely. I retain all rights to reuse my own code. There is no patent exposure so an Apache2.0 patent grant is not required and copyleft serves no goal of mine.

# Failure Dectection Record in Harness 
./test_selfcheck
RUN  test_passes
ok   test_passes
RUN  test_fails_on_purpose
  test_selfcheck.c:11: ASSERT_TRUE(1 == 2)
FAIL test_fails_on_purpose
1/2 passed
make: *** [Makefile:<line>: <target>] Error 1


./test_selfcheck || true
RUN  test_passes
ok   test_passes
RUN  test_fails_on_purpose
  test_selfcheck.c:11: ASSERT_TRUE(1 == 2)
FAIL test_fails_on_purpose
1/2 passed


# Clock Module
abort() is owed. When clock_gettime() fails, its possinble failures are programming bugs
clock_set_mono_source used to install fake time. Only allows switches with monotonic clock.
Pure conversion function helper to convert ```struct timespec's tv_sec``` seconds to na nanoseconds. Tested with hand-made input in ```test_clock.c```
