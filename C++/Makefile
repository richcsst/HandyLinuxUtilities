CXX      := g++
CXXFLAGS := -Wall -Wextra -O2 -std=c++17
LDFLAGS  := -lcurl

PREFIX   ?= /usr/local
BINDIR   := $(PREFIX)/bin

TARGETS  := wimip showenv cpu_cores

.PHONY: all clean install uninstall

all: $(TARGETS)

wimip: wimip.cpp
	$(CXX) $(CXXFLAGS) $< -o $@ $(LDFLAGS)

showenv: showenv.cpp
	$(CXX) $(CXXFLAGS) $< -o $@

cpu_cores: cpu_cores.cpp
	$(CXX) $(CXXFLAGS) $< -o $@

clean:
	rm -f $(TARGETS)

install: all
	install -d $(DESTDIR)$(BINDIR)
	install -m 0755 wimip $(DESTDIR)$(BINDIR)/wimip
	install -m 0755 showenv $(DESTDIR)$(BINDIR)/showenv
	install -m 0755 cpu_cores $(DESTDIR)$(BINDIR)/cpu_cores

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/wimip $(DESTDIR)$(BINDIR)/showenv $(DESTDIR)$(BINDIR)/cpu_cores

