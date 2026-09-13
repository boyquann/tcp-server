CC= gcc
CFLAGS= -Iinclude -O0 -Wall -Wextra -Werror -Wpedantic -std=c99 -fsanitize=undefined -g
MMDFLAGS= -MMD -MP

SRCS= $(wildcard src/*.c)
OBJS= $(SRCS:src/%.c=build/%.o)
DEPS= $(OBJS:.o=.d)
EXEC= tcp

.PHONY: all clean

all: $(EXEC)

$(EXEC): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(EXEC)

build/%.o : src/%.c | build
	$(CC) $(CFLAGS) $(MMDFLAGS) -c $< -o $@

-include $(DEPS)

build:
	mkdir -p build

clean:
	rm -rf $(EXEC) build
