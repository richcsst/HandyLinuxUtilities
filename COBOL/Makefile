COBC     := cobc
COBFLAGS := -x -O2

PREFIX   ?= /usr/local
BINDIR   := $(PREFIX)/bin

TARGETS  := wimip show-env cpu-cores

.PHONY: all clean install uninstall

all: $(TARGETS)

wimip: wimip.cob
	$(COBC) $(COBFLAGS) -o $@ $<

show-env: show-env.cob
	$(COBC) $(COBFLAGS) -o $@ $<

cpu-cores: cpu-cores.cob
	$(COBC) $(COBFLAGS) -o $@ $<

clean:
	rm -f $(TARGETS) env.tmp api.tmp

install: all
	install -d $(DESTDIR)$(BINDIR)
	install -m 0755 wimip $(DESTDIR)$(BINDIR)/wimip
	install -m 0755 show-env $(DESTDIR)$(BINDIR)/show-env
	install -m 0755 cpu-cores $(DESTDIR)$(BINDIR)/cpu-cores

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/wimip $(DESTDIR)$(BINDIR)/show-env $(DESTDIR)$(BINDIR)/cpu-cores

