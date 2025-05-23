# My makefile

This the makefile that I use to build my C/C++ code.
I accumulated this over a few years with the help of LLMs.

## What it does

- It assumes C is used.
- Defines `src`, `inc`, `bin`, `obj`, `lib` directories.
- Finds all `.c` files in `src` directory and its subdirectories.
- Generates object file paths by replacing `src` with `obj` and `.c` with `.o`.
- Finds all subdirectories in `inc` directory and adds `-I` flags.
- Generates dependency files.
- Compiles `.c` files into `.o` files, preserving directory structure.
- Links object and archive files into executable files.
- Runs the executable file.

## How to use

- Put your code in `src` directory.
- Put your header files in `inc` directory.
- Put your library files in `lib` directory.
- Run `make run` to run the executable file.
- Run `make clean` to clean up the object files and executable files.

Refer to `make help` to see all the commands.
