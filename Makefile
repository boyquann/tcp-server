SHELL:= /bin/bash
.SHELLFLAGS:= -eu -o pipefail -c
.DEFAULT_GOAL:= debug
.DELETE_ON_ERROR:
.PHONY: check-purity purity-run canaries debug vg release faultinj analyze tsan fuzz test check-full check check-purity canaries valgrind clean help artifacts unit vg-run 

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

artifacts : $(TCPD) $(TEST_BINS)

TEST_SRCS:= $(wildcard tests/unit/test_*.c)
TEST_OBJS:= $(TEST_SRCS:tests/unit/%.c=$(BUILD)/tests/%.o)
TEST_BINS:= $(TEST_OBJS:.o=)
DEPS += $(TEST_OBJS:.o=.d)

$(BUILD)/tests:
	mkdir -p $@

$(BUILD)/tests/%.o : tests/unit/%.c | $(BUILD)/tests
	$(CC) $(CSTD) $(CPPDEFS) $(CPPFLAGS) $(WARN) $(VFLAGS) $(CFLAGS) $(DEPFLAGS) -c $< -o $@

$(BUILD)/tests/% : $(BUILD)/tests/%.o $(MOD_OBJS)
	$(CC) $(VLDFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@

VARIANTS:= debug faultinj analyze release vg

$(VARIANTS):
	@$(MAKE) --no-print-directory VARIANT=$@ artifacts

tsan:
	@echo "tsan: not applicable until Phase 4"

fuzz:
	@echo "fuzz: not applicable until Phase 3"

test : unit

check:
	@$(MAKE) --no-print-directory VARIANT=debug artifacts unit canaries
	@$(MAKE) --no-print-directory check-purity

RUN_WITH:=

unit vg-run : $(TEST_BINS)
	@failed=0; \
	for t in $(TEST_BINS); do \
		$(RUN_WITH) $$t || failed=1; \
	done; \
	exit $$failed

vg-run : RUN_WITH = $(VALGRIND)

valgrind:
	@$(MAKE) --no-print-directory VARIANT=vg vg-run

check-full : check
	@$(MAKE) --no-print-directory VARIANT=vg vg-run
	@$(MAKE) --no-print-directory VARIANT=analyze artifacts
	@$(MAKE) --no-print-directory VARIANT=release unit
	@$(MAKE) --no-print-directory tsan fuzz

CANARY_DIR:= $(BUILD)/canaries
CANARY_BASE:= $(CSTD) $(CPPDEFS) -O0 -g
CANARIES:= asan_heap vg_fd vg_leak ubsan_overflow
CANARY_BINS:= $(CANARIES:%=$(CANARY_DIR)/%)

$(CANARY_DIR):
	mkdir -p $@

$(CANARY_DIR)/%: tests/tooling/canary_%.c | $(CANARY_DIR)
	$(CC) $(CANARY_BASE) $(CANARY_FLAGS) $< -o $@

$(CANARY_DIR)/asan_heap: CANARY_FLAGS:= $(SAN) -fno-sanitize-recover=all
$(CANARY_DIR)/ubsan_overflow: CANARY_FLAGS:= -fsanitize=undefined -fno-sanitize-recover=all
$(CANARY_DIR)/vg_leak: CANARY_FLAGS:= 
$(CANARY_DIR)/vg_fd: CANARY_FLAGS:=

canaries : $(CANARY_BINS)
	@tests/tooling/run_canary.sh asan must-fail "heap-buffer-overflow" $(CANARY_DIR)/asan_heap
	@tests/tooling/run_canary.sh ubsan must-fail "signed integer overflow" $(CANARY_DIR)/ubsan_overflow
	@tests/tooling/run_canary.sh vg-leak must-fail "definitely lost" $(VALGRIND) $(CANARY_DIR)/vg_leak
	@tests/tooling/run_canary.sh vg-fd must-fail "Open file descriptor" $(VALGRIND) $(CANARY_DIR)/vg_fd
	@tests/tooling/run_canary.sh analyzer must-fail "analyzer-use-after-free" \
		$(CC) $(CANARY_BASE) -fanalyzer -Werror -c tests/tooling/canary_analyzer_uaf.c -o /dev/null

PURE_SRCS:=
PURE_OBJS:=$(PURE_SRCS:src/%.c=$(BUILD)/%.o)

$(CANARY_DIR)/impure.o: tests/tooling/canary_impure.c| $(CANARY_DIR)
	$(CC) $(CANARY_BASE) -O2 -c $< -o $@

check-purity:
	@$(MAKE) --no-print-directory VARIANT=release purity-run

purity-run: $(PURE_OBJS) $(CANARY_DIR)/impure.o
	@tests/tooling/check_purity.sh $(PURE_OBJS)
	@tests/tooling/run_canary.sh purity must-fail "write" \
		tests/tooling/check_purity.sh $(CANARY_DIR)/impure.o

clean:
	rm -rf build

help:
	@echo "Build variants (default: debug):"
	@echo "   debug          ASan and UBSan, no optimisation"
	@echo "   faultinj       debug and fault injection"
	@echo "   vg             no sanitizers, for Valgrind"
	@echo "   release        -O2, for benchmarks"
	@echo "   analyze        GCC static analyzer"
	@echo "Checks:"
	@echo "   unit           build and run unit tests (urrent VARIANT)"
	@echo "   test           all tests for the current VARIANT"
	@echo "   valgrind       unit tests under Valgrind"
	@echo "   check          debug build and tests"
	@echo "   check-full     every check across every variant"
	@echo "Other:"
	@echo "   clean          delete the build/ directory containing all variants"
	@echo "Options: VARIANT=<name> WERROR=0"


-include $(DEPS)
