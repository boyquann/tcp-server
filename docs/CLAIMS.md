## VALGRIND
On Valgrind 3.26.0, a leaked fd counts as an error and it changes the exit status when ```--error-exitcod```e is set. Any test that therefore leaks a file descriptor will fail under ```make valgrind``` (INV-07)
