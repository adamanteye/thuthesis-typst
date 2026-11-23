MAKEFLAGS    += --no-builtin-rules
SHELL        := /bin/bash
TYPST        ?= typst
FONT_DIR     := fonts
TYPST_ARGS   ?= --font-path $(FONT_DIR)
CTAN_MIRROR  ?= https://mirrors.tuna.tsinghua.edu.cn/CTAN
OPEN_ZIPS    := $(addprefix $(FONT_DIR)/,fandol.zip xits.zip tex-gyre.zip)
WIN_PACKAGES := $(addprefix $(FONT_DIR)/, \
	Microsoft-Windows-LanguageFeatures-Fonts-Hans-Package-amd64.cab \
	Microsoft-Windows-Client-Desktop-Required-Package.ESD)

.DEFAULT_GOAL := thesis.pdf
.DELETE_ON_ERROR:
.INTERMEDIATE: $(OPEN_ZIPS) $(WIN_PACKAGES) $(FONT_DIR)/windows.json
.PHONY: clean fonts watch

%.pdf: %.typ fonts
	$(TYPST) compile --root .. $(TYPST_ARGS) $< $@

watch: fonts
	$(TYPST) watch --root .. $(TYPST_ARGS) thesis.typ thesis.pdf

fonts: $(FONT_DIR)/.open-fonts.ready
# ifeq ($(WIN),y)
# fonts: $(FONT_DIR)/.windows.ready
# endif

$(FONT_DIR)/%.zip:
	mkdir -p "$(@D)"
	curl -fsSL --retry 3 "$(CTAN_MIRROR)/fonts/$(@F)" -o "$@"

$(FONT_DIR)/.open-fonts.ready: $(OPEN_ZIPS)
	for pkg in $^; do unzip -joq "$$pkg" '*.otf' -d "$(@D)" || exit; done
	touch "$@"

$(FONT_DIR)/windows.json:
	mkdir -p "$(@D)"
	api=$${UUP_API:-https://api.uupdump.net}; \
	build=$$(curl -fsSLG --retry 3 "$$api/listid.php" --data sortByDate=1 \
	--data-urlencode "search=$${UUP_SEARCH:-Windows 11 24H2 amd64}" | \
	jq -er '[.response.builds[] | select(.arch == "amd64" and .uuid)] | max_by(.created).uuid') && \
	curl -fsSL --retry 3 "$$api/get.php?id=$$build" -o "$@"

$(WIN_PACKAGES): $(FONT_DIR)/windows.json
	curl -fL --retry 3 -o "$@" "$$(jq -r --arg name "$(@F)" \
		'.response.files | with_entries(.key |= ascii_downcase) | .[$$name | ascii_downcase].url' "$<")"

$(FONT_DIR)/.windows.ready: $(WIN_PACKAGES)
	for pkg in $^; do \
		7z e -y -ssc- -o"$(@D)" "$$pkg" -ir'!'{arial,cour,times}{,bd,i,bi}.ttf \
		-ir'!'{simsun.ttc,simhei.ttf,simkai.ttf,simfang.ttf} || exit; \
	done
	touch "$@"

clean:
	rm -f thesis.pdf
