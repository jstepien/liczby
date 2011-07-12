.PHONY: all clean

GHCFLAGS ?= -O3

all: liczby

liczby: liczby.lhs
	ghc --make $(GHCFLAGS) $< -o $@

liczby.lhs: README.md
	sed $< -e 's/^    /> /' -e 's/^#\+//' > $@

clean:
	rm -f liczby liczby.o liczby.hi liczby.lhs
