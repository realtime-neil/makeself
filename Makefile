# makeself/Makefile

.POSIX:

# https://www.gnu.org/prep/standards/standards.html#Makefile-Conventions
.SUFFIXES:
SHELL = /bin/sh
INSTALL = install
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 644
srcdir = .
prefix = /usr/local
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin
datarootdir = $(prefix)/share
datadir = $(datarootdir)
docdir = $(datarootdir)/doc/makeself
mandir = $(datarootdir)/man
man1dir = $(mandir)/man1

PACKAGE := makeself
VERSION != cat VERSION
OUTPUT  := $(PACKAGE)-$(VERSION).run
SRCS := COPYING Makefile README.md VERSION makeself-header.sh makeself.lsm makeself.sh test
SRCDIR_SRCS != echo "$(SRCS)" | sed 's, \b, $(srcdir)/,g'

all: $(OUTPUT)

install: makeself.sh makeself-header.sh makeself.1
	mkdir -p \
		$(DESTDIR)$(bindir) \
		$(DESTDIR)$(datadir)/makeself \
		$(DESTDIR)$(docdir) \
		$(DESTDIR)$(man1dir)
	$(INSTALL_DATA) \
		$(srcdir)/makeself.1 \
		$(DESTDIR)$(man1dir)
	$(INSTALL_DATA) \
		$(srcdir)/README.md \
		$(DESTDIR)$(docdir)
	$(INSTALL_DATA) \
		$(srcdir)/makeself-header.sh \
		$(DESTDIR)$(datadir)/makeself
	$(INSTALL_PROGRAM) \
		$(srcdir)/makeself.sh \
		$(DESTDIR)$(bindir)/makeself
	sed -i 's,^HEADER=.*$$,HEADER=$(DESTDIR)$(datadir)/makeself/makeself-header.sh,' \
		$(DESTDIR)$(bindir)/makeself

uninstall:
	rm -f \
		$(DESTDIR)$(man1dir)/makeself.1 \
		$(DESTDIR)$(docdir)/README.md \
		$(DESTDIR)$(datadir)/makeself/makeself-header.sh \
		$(DESTDIR)$(bindir)/makeself
	rmdir \
		$(DESTDIR)$(datadir)/makeself \
		$(DESTDIR)$(docdir)

clean:
	rm -f $(OUTPUT)

distclean: clean
	rm -f $(PACKAGE)-$(VERSION).tar.gz
	rm -rf $(PACKAGE)-$(VERSION)

dist: $(PACKAGE)-$(VERSION).tar.gz

$(PACKAGE)-$(VERSION).tar.gz: $(SRCS)
	mkdir $(PACKAGE)-$(VERSION)
	cp -a $(SRCDIR_SRCS) $(PACKAGE)-$(VERSION)
	tar -czf $@ $(PACKAGE)-$(VERSION)

check:
	{ set -eu \
	; cd $(srcdir)/test \
	; ./appendtest \
	; ./corrupttest \
	; ./datetest \
	; ./extracttest \
	; ./nohardlinktest \
	; ./onefiledirtest \
	; ./suidtest \
	; ./tarextratest \
	; ./variabletest \
	; ./whitespacelicense \
	; ./whitespacetest \
	; }

self: $(OUTPUT)
release: $(OUTPUT)
$(OUTPUT): $(SRCS)
	{ set -eu \
	; archive_dir="$$(mktemp -dt archive_dir.XXXXXX)" \
	; cp -a $(SRCDIR_SRCS) "$${archive_dir}" \
	; $(srcdir)/makeself.sh --notemp \
		"$${archive_dir}" \
		$@ \
		"Makeself v$VER" \
		echo "Makeself has extracted itself" \
	; rm -rf "$${archive_dir}" \
	; }
