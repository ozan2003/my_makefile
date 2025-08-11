CC := gcc

BUILD ?= debug

WARNFLAGS := -Wall -Wextra -Wpedantic -Wshadow -Werror \
	-pedantic-errors -Wlogical-op -Wcast-qual -Wstrict-aliasing -Wpointer-arith -Wcast-align -Wwrite-strings \
	-Wswitch-default -Wunreachable-code -Wswitch-enum -Wformat=2 -Wunused-macros \
	-Winit-self -Wundef -Wuninitialized -Wbad-function-cast -Wno-unused-parameter \
	-Wredundant-decls -Wno-unused-result -Wduplicated-branches -Wduplicated-cond \
	-Wno-missing-braces -Wmissing-include-dirs \
	-Wmissing-format-attribute -Wmissing-noreturn -Wmissing-parameter-type

ifeq ($(BUILD),debug)
    CFLAGS := -fdiagnostics-color=always -O0 -g -std=c99 $(WARNFLAGS)
else ifeq ($(BUILD),release)
    CFLAGS := -fdiagnostics-color=always -O2 -std=c99 $(WARNFLAGS)
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
TARGET_EXEC := main.out

SOURCES := $(shell find $(SRC_DIR) -name '*.c')
OBJECTS := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SOURCES))
DEPFILES := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.d,$(SOURCES))

INC_PARAMS := $(addprefix -I,$(shell find $(INC_DIR) -type d))

# Automatically detect static libraries and convert to linker flags
LIBRARIES := $(wildcard $(LIB_DIR)/lib*.a)
LIB_FLAGS := $(patsubst $(LIB_DIR)/lib%.a,-l%,$(LIBRARIES))
LIBS := -L$(LIB_DIR) $(LIB_FLAGS)

-include $(DEPFILES)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(INC_PARAMS) -MMD -MP -MF $(OBJ_DIR)/$*.d -c $< -o $@

$(BIN_DIR)/$(TARGET_EXEC): $(OBJECTS)
	@mkdir -p $(BIN_DIR)
	$(CC) $(CFLAGS) $^ $(LIBS) -o $@

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
