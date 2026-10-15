# D-0001 :LICENSE 
**Decision:** This work is under the MIT License as its purpose is to be read and reused freely. I retain all rights to reuse my own code. There is no patent exposure so an Apache2.0 patent grant is not required and copyleft serves no goal of mine.


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

