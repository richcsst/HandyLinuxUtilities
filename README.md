# HandyLinuxUtilities

A collection of small utilities for Linux. This repository includes showenv, a small C program that prints environment variables with colorized output and helpful highlighting.

## showenv

showenv is a C port of the original Perl script showenv.pl. It lists environment variables, aligns names, highlights IPv4 addresses, and applies colors to known substrings such as "truecolor", "256color", various distro names, and "wayland".

### Build

Requirements: a C compiler (gcc/clang) and make.

To build:

    make

This produces the `showenv` binary.

### Install

By default, installation goes to /usr/local/bin. To install:

    sudo make install

Or change prefix:

    sudo make PREFIX=/opt install

### Usage

Run the binary:

    showenv

It will print environment variables to stdout with colored highlights. Use in a terminal that supports ANSI colors.

### Development

- The Makefile builds the program with `-std=c11 -Wall -Wextra -O2`.
- To clean the build artifact:

    make clean

### License

The original script was licensed under the Perl Artistic License 2.0. This repository follows the same licensing for the C port unless otherwise noted.

### Author

Richard Kelsch <rich@rk-internet.com>

