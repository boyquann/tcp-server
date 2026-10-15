SHELL:= /bin/bash
.SHELLFLAGS:= -eu -o pipefail -c
.DEFAULT_GOAL:= debug
.DELETE_ON_ERROR:
.PHONY: debug vg release faultinj analyze tsan fuzz test check-full check check-purity canaries valgrind clean help artifacts

CC:= gcc
PYTHON:= python3
VALGRIND:= valgrind --leak-check=full --show-leak-kinds=all --errors-for-leak-kinds=definite,indirect --track-fds=yes --trace-children=yes \
	   --error-exitcode=99
CSTD:= -std=c17
CPPDEFS:= -D_POSIX_C_SOURCE=200809L -Isrc
WARN := -Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wsign-conversion -Wformat=2 -Wstrict-prototypes -Wmissing-prototypes -Wold-style-definition \
	-Wcast-align=strict -Wcast-qual -Wundef -Wvla -Wnull-dereference -Wdouble-promotion
DEPFLAGS:= -MMD -MP

WERROR ?= 1
ifeq ($(WERROR),1)
	WARN += -Werror
endif

ifneq ($(WERROR),0)
ifneq ($(WERROR),1)
$(error Invalid value for WERROR. Set to 0 or 1)
endif
endif

VARIANT ?= debug
BUILD:= build/$(VARIANT)
SAN:= -fsanitize=address,undefined
DEBUG_FLAGS:= -O0 -g3 $(SAN) -fno-sanitize-recover=all -fno-omit-frame-pointer

ifeq ($(VARIANT),debug)
VFLAGS:= $(DEBUG_FLAGS)
VLDFLAGS:= $(SAN)
else ifeq ($(VARIANT),faultinj)
VFLAGS:= $(DEBUG_FLAGS) -DTCPD_FAULT_INJECT
VLDFLAGS:= $(SAN)
else ifeq ($(VARIANT),vg)
VFLAGS:= -O0 -g3
VLDFLAGS:= 
else ifeq ($(VARIANT),release)
VFLAGS:= -O2 -g -DNDEBUG
VLDFLAGS:=
else ifeq ($(VARIANT),analyze)
VFLAGS:= -O0 -g -fanalyzer
VLDFLAGS:=
else
$(error Unknown VARIANT '$(VARIANT)'. Use: debug, release, analyse, vg, faultinj)
endif

MAIN_SRC:= src/main.c
MOD_SRCS:= src/clock.c src/config.c src/errclass.c src/log.c 
MAIN_OBJ:= $(MAIN_SRC:src/%.c=$(BUILD)/%.o)
MOD_OBJS:= $(MOD_SRCS:src/%.c=$(BUILD)/%.o)
DEPS:= $(MAIN_OBJ:.o=.d) $(MOD_OBJS:.o=.d)

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/%.o : src/%.c | $(BUILD)
	$(CC) $(CSTD) $(CPPDEFS) $(CPPFLAGS) $(WARN) $(VFLAGS) $(CFLAGS) $(DEPFLAGS) -c $< -o $@

TCPD:= $(BUILD)/tcpd

$(TCPD) : $(MAIN_OBJ) $(MOD_OBJS)
	$(CC) $(VLDFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@

artifacts: $(TCPD)













-include $(DEPS)


