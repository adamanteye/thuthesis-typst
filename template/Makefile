MAKEFLAGS           += --no-builtin-rules
SHELL               := /bin/bash
TYPST               ?= typst
FONT_DIR            := fonts
FANDOL_ARCHIVE      := .fandol.zip
XITS_ARCHIVE        := .xits.zip
TEX_GYRE_ARCHIVE    := .tex-gyre.zip
OPEN_FONTS_STAMP    := $(FONT_DIR)/.open-fonts.ready
WINDOWS_FONTS_STAMP := $(FONT_DIR)/.windows.ready
WINDOWS_FONT_SCRIPT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))download-windows-fonts.sh
WINDOWS_UUP_SEARCH  ?= Windows 11 24H2 amd64
WINDOWS_UUP_ARCH    ?= amd64
TYPST_ARGS          ?= --font-path $(FONT_DIR)
.PHONY: clean fonts help watch

%.pdf: %.typ fonts
	$(TYPST) compile --root .. $(TYPST_ARGS) $< $@

watch: fonts
	$(TYPST) watch --root .. $(TYPST_ARGS) thesis.typ thesis.pdf

help:
	@printf '%s\n' \
		'Usage:' \
		'  make [target] [WIN=y]' \
		'' \
		'Targets:' \
		'  thesis.pdf       Compile the example thesis.' \
		'  watch            Recompile the example thesis when files change.' \
		'  fonts            Download the open Fandol, XITS, and TeX Gyre fonts.' \
		'  clean            Remove the compiled example PDF.' \
		'  help             Show this help.' \
		'' \
		'Windows fonts on Linux:' \
		'  make WIN=y fonts' \
		'' \
		'  This command queries UUP dump for a Windows build, downloads the required' \
		'  components from Microsoft delivery servers, checks the archives, and extracts' \
		'  the fonts into fonts/. It requires curl, jq, 7z, and about 1 GiB of temporary' \
		'  disk space. The command displays the Microsoft license warning and continues' \
		'  only after the user explicitly enters y.' \
		'  WINDOWS_UUP_SEARCH and WINDOWS_UUP_ARCH can override the build query.' \
		'' \
		'  Other operating systems should copy licensed Windows font files into fonts/.'

# Microsoft Windows fonts are proprietary. `make WIN=y fonts` asks for explicit
# license confirmation, then discovers Microsoft component URLs through UUP dump.
FONT_TARGETS := $(OPEN_FONTS_STAMP)
ifeq ($(WIN),y)
FONT_TARGETS += $(WINDOWS_FONTS_STAMP)
endif

fonts: $(FONT_TARGETS)

$(OPEN_FONTS_STAMP):
	mkdir -p $(FONT_DIR)
	curl --proto '=https' --tlsv1.2 -sSLf https://mirrors.ctan.org/fonts/fandol.zip -o $(FANDOL_ARCHIVE)
	unzip -q $(FANDOL_ARCHIVE) -d $(FONT_DIR)
	curl --proto '=https' --tlsv1.2 -sSLf https://mirrors.ctan.org/fonts/xits.zip -o $(XITS_ARCHIVE)
	unzip -q $(XITS_ARCHIVE) -d $(FONT_DIR)
	curl --proto '=https' --tlsv1.2 -sSLf https://mirrors.ctan.org/fonts/tex-gyre.zip -o $(TEX_GYRE_ARCHIVE)
	unzip -q $(TEX_GYRE_ARCHIVE) -d $(FONT_DIR)
	touch $@
	rm -f $(FANDOL_ARCHIVE) $(XITS_ARCHIVE) $(TEX_GYRE_ARCHIVE)

$(WINDOWS_FONTS_STAMP): $(WINDOWS_FONT_SCRIPT)
	bash "$(WINDOWS_FONT_SCRIPT)" "$(FONT_DIR)" "$(WINDOWS_UUP_SEARCH)" "$(WINDOWS_UUP_ARCH)"
	touch $@

clean:
	rm -f thesis.pdf

.DELETE_ON_ERROR:
.DEFAULT_GOAL := thesis.pdf
