# Compiler and Flags
CC      := gcc
CFLAGS  := -Wall -Wextra -O2
LDFLAGS := -lcurl -ljson-c

# Installation Directories (Standard GNU path conventions)
PREFIX      ?= /usr/local
BINDIR      := $(PREFIX)/bin

# Target Executables
TARGETS := wimip showenv cpu_cores

.PHONY: all clean install uninstall

# Default target: build all three binaries
all: $(TARGETS)

# Compilation rules
wimip: wimip.c
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)

showenv: showenv.c
	$(CC) $(CFLAGS) $< -o $@

cpu_cores: cpu_cores.c
	$(CC) $(CFLAGS) $< -o $@

# Clean build artifacts
clean:
	rm -f $(TARGETS)

# Installation target (Requires appropriate privileges, e.g., sudo)
install: all
	@echo "Installing binaries to $(DESTDIR)$(BINDIR)..."
	install -d $(DESTDIR)$(BINDIR)
	install -m 0755 wimip $(DESTDIR)$(BINDIR)/wimip
	install -m 0755 showenv $(DESTDIR)$(BINDIR)/showenv
	install -m 0755 cpu_cores $(DESTDIR)$(BINDIR)/cpu_cores
	@echo "All binaries installed successfully!"

# Uninstallation target
uninstall:
	@echo "Removing binaries from $(DESTDIR)$(BINDIR)..."
	rm -f $(DESTDIR)$(BINDIR)/wimip
	rm -f $(DESTDIR)$(BINDIR)/showenv
	rm -f $(DESTDIR)$(BINDIR)/cpu_cores
	@echo "Uninstallation complete."

