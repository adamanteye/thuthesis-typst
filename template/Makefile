MAKEFLAGS           += --no-builtin-rules
SHELL               := /bin/bash
TYPST               ?= typst
FONT_DIR            := fonts
CTAN_MIRROR         ?= https://mirrors.tuna.tsinghua.edu.cn/CTAN
OPEN_FONTS_STAMP    := $(FONT_DIR)/.open-fonts.ready
WINDOWS_FONTS_STAMP := $(FONT_DIR)/.windows.ready
WINDOWS_FONT_SCRIPT := $(dir $(lastword $(MAKEFILE_LIST)))download-windows-fonts.sh
TYPST_ARGS          ?= --font-path $(FONT_DIR)
.PHONY: clean fonts help watch

%.pdf: %.typ fonts
	$(TYPST) compile --root .. $(TYPST_ARGS) $< $@

watch: fonts
	$(TYPST) watch --root .. $(TYPST_ARGS) thesis.typ thesis.pdf

help:
	@printf '%s\n' \
		'Usage: make [target] [WIN=y]' \
		'' \
		'Targets:' \
		'  thesis.pdf  Compile the example thesis.' \
		'  watch       Recompile on file changes.' \
		'  fonts       Download open fonts (add WIN=y for licensed Windows fonts).' \
		'  clean       Remove the compiled example PDF.' \
		'  help        Show this help.' \
		'' \
		'Variables: CTAN_MIRROR (default: TUNA), TYPST, TYPST_ARGS.'

FONT_TARGETS := $(OPEN_FONTS_STAMP)
ifeq ($(WIN),y)
FONT_TARGETS += $(WINDOWS_FONTS_STAMP)
endif

fonts: $(FONT_TARGETS)

$(OPEN_FONTS_STAMP):
	mkdir -p $(FONT_DIR)
	set -euo pipefail; \
	tmp=$$(mktemp -d); trap 'rm -rf "$$tmp"' EXIT; \
	for pkg in fandol xits tex-gyre; do \
		curl --proto '=https' --tlsv1.2 -fsSL --retry 3 "$(CTAN_MIRROR)/fonts/$$pkg.zip" -o "$$tmp/$$pkg.zip"; \
		unzip -joq "$$tmp/$$pkg.zip" '*.otf' -d "$(FONT_DIR)"; \
	done
	touch $@

$(WINDOWS_FONTS_STAMP): $(WINDOWS_FONT_SCRIPT)
	bash "$(WINDOWS_FONT_SCRIPT)" "$(FONT_DIR)"
	touch $@

clean:
	rm -f thesis.pdf

.DELETE_ON_ERROR:
.DEFAULT_GOAL := thesis.pdf
