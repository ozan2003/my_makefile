CXX := g++

BUILD ?= debug
TARGET_EXEC ?= $(notdir $(CURDIR)).out
CXXSTD ?= c++23

SRC_DIR := ./src
INC_DIR := ./include
BIN_DIR := ./bin
# store compiled object files
OBJ_DIR := ./obj
# holds static libraries
LIB_DIR := ./lib
RM := rm -f

WARNFLAGS := -Wall -Wextra -Wpedantic -Wshadow -Werror \
	-pedantic-errors -Wlogical-op -Wcast-qual -Wstrict-aliasing=3 -Wpointer-arith \
	-Wcast-align=strict -Wdouble-promotion -Wsuggest-override \
	-Wswitch-default -Wswitch-enum \
	-Wformat=2 -Wformat-truncation=2 -Wformat-overflow=2 \
	-Wformat-signedness -Wformat-nonliteral \
	-Wunused-macros \
	-Wundef -Wuninitialized \
	-Wredundant-decls -Wduplicated-branches -Wduplicated-cond \
	-Wmissing-include-dirs -Wconversion -Wsign-conversion -Wextra-semi \
	-Wmissing-format-attribute -Wmissing-noreturn \
	-Wnull-dereference -Wimplicit-fallthrough=5 -Wvla -Wold-style-cast \
	-Woverloaded-virtual -Wnon-virtual-dtor \
	-Wuseless-cast -Wzero-as-null-pointer-constant \
	-Wmissing-declarations \
	-Wfloat-equal \
	-Walloc-zero \
	-Walloca \
	-Wwrite-strings \
	-Winit-self \
	-Warith-conversion \
	-Warray-bounds=2 \
	-Wstringop-overflow=4 \
	-Wuse-after-free=3 \
	-Wattribute-alias=2 \
	-Wflex-array-member-not-at-end \
	-Wtrampolines \
	-Wbidi-chars=any \
	-Wstack-protector

# Compiler flags
DEBUGFLAGS := -O0 \
	-g3 \
	-fno-omit-frame-pointer \
	-fanalyzer

# Sanitizer flags
SANITIZEFLAGS := -fsanitize=address,undefined

# Linker flags
LDFLAGS := -L$(LIB_DIR)
# The libraries to link with
LDLIBS :=

ifeq ($(BUILD),debug)
	CXXFLAGS := -fdiagnostics-color=always -std=$(CXXSTD) $(WARNFLAGS) $(DEBUGFLAGS) $(SANITIZEFLAGS)
	# Add sanitizer flags to the linker libraries
	LDLIBS += $(SANITIZEFLAGS)
else ifeq ($(BUILD),release)
	CXXFLAGS := -fdiagnostics-color=always -O2 -DNDEBUG -std=$(CXXSTD) $(WARNFLAGS)
	CXXFLAGS += -fstack-protector-strong -D_FORTIFY_SOURCE=3
else
	$(error BUILD must be either 'debug' or 'release')
endif

SOURCES := $(shell find $(SRC_DIR) \( -name '*.cpp' -o -name '*.cc' -o -name '*.cxx' \) -type f)
OBJECTS := $(patsubst $(SRC_DIR)/%,$(OBJ_DIR)/%.o,$(basename $(SOURCES)))
DEPFILES := $(OBJECTS:.o=.d)

INC_PARAMS := $(addprefix -I,$(shell find $(INC_DIR) -type d))
# Preprocessor flags
CPPFLAGS := $(INC_PARAMS)

# Automatically detect static libraries and convert to linker flags
LIBRARIES := $(wildcard $(LIB_DIR)/lib*.a)
LIB_FLAGS := $(patsubst $(LIB_DIR)/lib%.a,-l%,$(LIBRARIES))
LDLIBS += -Wl,--start-group $(LIB_FLAGS) -Wl,--end-group

.DEFAULT_GOAL := all

-include $(DEPFILES)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MMD -MP -MF $(OBJ_DIR)/$*.d -c $< -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MMD -MP -MF $(OBJ_DIR)/$*.d -c $< -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cxx
	@mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MMD -MP -MF $(OBJ_DIR)/$*.d -c $< -o $@

$(BIN_DIR)/$(TARGET_EXEC): $(OBJECTS)
	@mkdir -p $(BIN_DIR)
	$(CXX) $^ $(LDFLAGS) $(LDLIBS) -o $@

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
rebuild:
	$(MAKE) clean
	$(MAKE) all

.PHONY: help
help:
	@echo "\033[1;34mUsage: make [all|run|clean|distclean|rebuild|help] [BUILD=debug|release] [CXXSTD=c++23]\033[0m"
	@echo "  \033[1;32mall\033[0m:       Compile the project"
	@echo "  \033[1;32mrun\033[0m:       Compile and run the project"
	@echo "  \033[1;32mclean\033[0m:     Remove compiled files"
	@echo "  \033[1;32mdistclean\033[0m: Remove compiled files and directories"
	@echo "  \033[1;32mrebuild\033[0m:   Clean and recompile the project"
	@echo "  \033[1;32mhelp\033[0m:      Display this help message"
	@echo "  \033[1;32mBUILD\033[0m:     Set to debug (default) or release"
	@echo "  \033[1;32mCXXSTD\033[0m:    Set C++ standard (default: C++23)"
