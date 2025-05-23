CC := gcc
CCFLAGS := -fdiagnostics-color=always -O1 -std=c99 -Wall -Wextra -Wpedantic -Wshadow -Werror \
			-pedantic-errors -Wlogical-op -Wcast-qual -Wstrict-aliasing -Wpointer-arith -Wcast-align -Wwrite-strings \
			-Wswitch-default -Wunreachable-code -Wswitch-enum -Wformat=2 -Wunused-macros \
			-Winit-self -Wundef -Wuninitialized -Wbad-function-cast -Wno-unused-parameter \
			-Wredundant-decls -Wno-unused-result -Wduplicated-branches -Wduplicated-cond \
			-Wcast-qual -Wno-missing-braces -Wmissing-include-dirs \
			-Wmissing-format-attribute -Wmissing-noreturn -Wmissing-parameter-type \
			
SRC_DIR := ./src
INC_DIR := ./include
BIN_DIR := ./bin
OBJ_DIR := ./obj
RM := rm -f
TARGET_EXEC := main.out

# Find all .c files in SRC_DIR and its subdirectories.
SOURCES := $(shell find $(SRC_DIR) -name '*.c')

# Generate object file paths by replacing SRC_DIR with OBJ_DIR and .c with .o.
OBJECTS := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SOURCES))

# Recursively find all subdirectories in INC_DIR and add -I flags.
INC_PARAMS := $(addprefix -I,$(shell find $(INC_DIR) -type d))

# Generate dependency files.
DEPFILES := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.d,$(SOURCES))
-include $(DEPFILES)

# Archive library handling.
LIB_DIR := ./lib
ARCHIVE_FILES := $(wildcard $(LIB_DIR)/*.a)

# Rule to compile .c files into .o files, preserving directory structure.
# Create the target directory if it doesn't exist.
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CCFLAGS) $(INC_PARAMS) -MMD -MF $(OBJ_DIR)/$*.d -c $< -o $@

# Link all object files into the final executable.
$(BIN_DIR)/$(TARGET_EXEC): $(OBJECTS)
	@mkdir -p $(BIN_DIR)
	$(CC) $(CCFLAGS) $^ $(ARCHIVE_FILES) -o $@

.PHONY: all
all: $(BIN_DIR)/$(TARGET_EXEC)

.PHONY: run
run: all
	$(BIN_DIR)/$(TARGET_EXEC)

# Delete only .o and .d files but keep the directory structure
.PHONY: clean
clean:
	$(RM) $(BIN_DIR)/$(TARGET_EXEC)
	find $(OBJ_DIR) -name "*.o" -type f -delete
	find $(OBJ_DIR) -name "*.d" -type f -delete

.PHONY: rebuild
rebuild: clean all

.PHONY: help
help:
	@echo "\033[1;34mUsage: make [all|run|clean|rebuild|help]\033[0m"
	@echo "  \033[1;32mall\033[0m:     Compile the project"
	@echo "  \033[1;32mrun\033[0m:     Compile and run the project"
	@echo "  \033[1;32mclean\033[0m:   Remove compiled files"
	@echo "  \033[1;32mrebuild\033[0m: Clean and recompile the project"
	@echo "  \033[1;32mhelp\033[0m:    Display this help message"