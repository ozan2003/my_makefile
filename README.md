# My makefile

This the makefile that I use to build my C/C++ code.
I compiled this over a few years, with some help from LLMs.

## What it does

- It assumes C++ is used.
- Source files can be `.cpp`, `.cc`, or `.cxx`.
- Defines `src`, `include`, `bin`, `obj`, `lib` directories.
- Finds all source files in `src` directory and its subdirectories.
- Generates object file paths by replacing `src` with `obj` and source file extension with `.o`.
- Finds all subdirectories in `include` directory and adds `-I` flags.
- Automatically detects and links static libraries from `lib` directory.
- Generates dependency files for automatic rebuilds.
- Compiles source files into `.o` files, preserving directory structure.
- Links object and library files into executable files.
- Supports debug and release build modes.
- Runs the executable file.

## How to use

- Put your code in `src` directory.
- Put your header files in `include` directory.
- Put your library files in `lib` directory.
- Run `make run` to compile and run the executable file.
- Run `make clean` to clean up the object files and executable files.
- Run `make BUILD=release` to build optimized version.
- Run `make distclean` to remove all generated files and directories.

Refer to `make help` to see all the commands.
