CC := gcc

BUILD ?= debug
TARGET_EXEC ?= $(notdir $(CURDIR)).out

# Compiler flags
WARNFLAGS := \
	-Wall -Wextra -Wpedantic -Werror -pedantic-errors \
	-Wshadow \
	-Wconversion -Wsign-conversion \
	-Wcast-qual -Wcast-align \
	-Wpointer-arith \
	-Wwrite-strings \
	-Wdouble-promotion \
	-Wstrict-prototypes \
	-Wold-style-definition \
	-Wswitch-enum -Wswitch-default \
	-Wformat=2 -Wformat-truncation=2 \
	-Wundef \
	-Wbad-function-cast \
	-Wredundant-decls \
	-Wvla \
	-Wimplicit-fallthrough=5 \
	-Wduplicated-cond \
	-Wduplicated-branches \
	-Wnull-dereference \
	-fno-common

DEBUGFLAGS := \
	-O1 \
	-g3 \
	-fno-omit-frame-pointer

# Sanitizer flags
SANITIZEFLAGS := -fsanitize=address,undefined

# Linker flags
LDFLAGS := -L$(LIB_DIR)
# The libraries to link with
LDLIBS := 

ifeq ($(BUILD),debug)
	CFLAGS := -fdiagnostics-color=always -O0 -g -std=c99 $(WARNFLAGS) $(DEBUGFLAGS) $(SANITIZEFLAGS)
	# Add sanitizer flags to the linker libraries
	LDLIBS += $(SANITIZEFLAGS)
else ifeq ($(BUILD),release)
	CFLAGS := -fdiagnostics-color=always -O2 -DNDEBUG -std=c99 $(WARNFLAGS)
	CFLAGS += -fstack-protector-strong -D_FORTIFY_SOURCE=3
else
	$(error BUILD must be either 'debug' or 'release')
endif

SRC_DIR := ./src
INC_DIR := ./include
BIN_DIR := ./bin
# store compiled object files
OBJ_DIR := ./obj
# holds static libraries
LIB_DIR := ./lib
RM := rm -f

SOURCES := $(shell find $(SRC_DIR) -name '*.c')
OBJECTS := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SOURCES))
DEPFILES := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.d,$(SOURCES))

INC_PARAMS := $(addprefix -I,$(shell find $(INC_DIR) -type d))
# C preprocessor flags
CPPFLAGS := $(INC_PARAMS)

# Automatically detect static libraries and convert to linker flags
LIBRARIES := $(wildcard $(LIB_DIR)/lib*.a)
LIB_FLAGS := $(patsubst $(LIB_DIR)/lib%.a,-l%,$(LIBRARIES))
# The libraries to link with
LDLIBS += -Wl,--start-group $(LIB_FLAGS) -Wl,--end-group

# Ensure the object directory exists before trying to include dependency files
$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

-include $(DEPFILES)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -MF $(OBJ_DIR)/$*.d -c $< -o $@

$(BIN_DIR)/$(TARGET_EXEC): $(OBJECTS) | $(OBJ_DIR)
	@mkdir -p $(BIN_DIR)
	$(CC) $^ $(LDFLAGS) $(LDLIBS) $(SANITIZEFLAGS) -o $@

.PHONY: all
all: $(BIN_DIR)/$(TARGET_EXEC)

.PHONY: run
run: all
	$(BIN_DIR)/$(TARGET_EXEC)

.PHONY: clean
clean:
	$(RM) $(BIN_DIR)/$(TARGET_EXEC)
	find $(OBJ_DIR) -name "*.o" -type f -delete
	find $(OBJ_DIR) -name "*.d" -type f -delete

.PHONY: distclean
distclean:
	$(RM) -r $(OBJ_DIR) $(BIN_DIR)

.PHONY: rebuild
rebuild: clean all

.PHONY: help
help:
	@echo "\033[1;34mUsage: make [all|run|clean|distclean|rebuild|help] [BUILD=debug|release]\033[0m"
	@echo "  \033[1;32mall\033[0m:       Compile the project"
	@echo "  \033[1;32mrun\033[0m:       Compile and run the project"
	@echo "  \033[1;32mclean\033[0m:     Remove compiled files"
	@echo "  \033[1;32mdistclean\033[0m: Remove compiled files and directories"
	@echo "  \033[1;32mrebuild\033[0m:   Clean and recompile the project"
	@echo "  \033[1;32mhelp\033[0m:      Display this help message"
	@echo "  \033[1;32mBUILD\033[0m:     Set to debug (default) or release"