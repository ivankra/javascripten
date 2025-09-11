SHELL := /bin/bash
DOCKER := $(shell command -v podman 2>/dev/null || echo docker)

ENGINES := $(patsubst %.Dockerfile,%,$(wildcard [a-z]*.Dockerfile))
ifeq ($(shell uname -m),aarch64)
  ENGINES := $(filter-out chakracore%,$(ENGINES))     # doesn't support arm64 linux
  ENGINES := $(filter-out iv-lv5-jitless,$(ENGINES))  # no JIT on arm64 anyway
  ENGINES := $(filter-out bali,$(ENGINES))            # doesn't build on arm64
  ENGINES := $(filter-out hako,$(ENGINES))            # doesn't build on arm64
  ENGINES := $(filter-out starlight,$(ENGINES))       # doesn't build on arm64
endif

ENGINES_MD := $(patsubst %.md,%,$(wildcard *.md))
ENGINES_MD := $(filter-out README,$(ENGINES_MD))

RUNTIMES := $(patsubst sh/%.Dockerfile,%,$(wildcard sh/[a-z]*.Dockerfile))
RUNTIMES := $(filter-out sh,$(RUNTIMES))

all: base $(ENGINES:%=.iid/%) $(RUNTIMES:%=.iid/%) bin

base: .iid/base .iid/sh

bin: $(patsubst %,bin/%,$(ENGINES)) $(patsubst %,bin/%,$(RUNTIMES))

sh: .iid/sh .PHONY
	$(DOCKER) run \
	  --rm \
	  -v $(PWD)/bench:/bench \
	  -v $(PWD):/work \
	  -w /work/bin \
	  -it \
	  javascripten-sh

clean-docker:
	rm -rf .iid
	-$(DOCKER) container prune
	-$(DOCKER) image rm `$(DOCKER) image ls | grep javascripten- | cut -f 1 -d ' '`
	-$(DOCKER) image rm javascripten-debian:stable javascripten-ubuntu:22.04
	$(DOCKER) image prune

define rules
$(1): .iid/$(1) bin/$(1)
	$(DOCKER) run \
	  --rm \
	  -v $(PWD)/bench:/bench \
	  -it \
	  javascripten-$(1)

$(1)-sh: .iid/$(1)
	$(DOCKER) run \
	  --rm \
	  -v $(PWD)/bench:/bench \
	  -it \
	  javascripten-$(1) \
	  /bin/bash -c 'ln -sv "$$$$JS_BINARY" "/bin/`basename $$$$JS_BINARY`"; /bin/bash -i'

.iid/$(1): $(2)$(1).Dockerfile $(3)
	PINNED_COMMIT=`sed -ne 's/^$(1) /--build-arg=JS_COMMIT=/p' .pins 2>/dev/null` \
	$(DOCKER) build \
	  -f $(2)$(1).Dockerfile \
	  -t javascripten-$(1) \
	  --iidfile=.iid/$(1) \
	  $$$$PINNED_COMMIT \
	  .
	@rm -f bin/$(1)

bin/$(1): .iid/$(1)
	@mkdir -p bin
	@rm -f "bin/$(1)"
	$(DOCKER) run --rm -v $(PWD)/bin:/dist -it javascripten-$(1) /bin/bash -c ' \
	  if [[ -f "$$$$JS_BINARY" ]]; then \
	    strip "$$$$JS_BINARY" 2>/dev/null && cp -fv "$$$$JS_BINARY" "/dist/$(1)"; \
	  elif [[ -f "$$$$JS_BINARY_LINK" ]]; then \
	    ln -sv "$$$$JS_BINARY_LINK" "/dist/$(1)"; \
	  fi' || true
endef

$(foreach var,$(ENGINES),$(eval $(call rules,$(var),,.iid/base)))
$(foreach var,$(RUNTIMES),$(eval $(call rules,$(var),sh/,.iid/sh)))

.iid/base: _base.Dockerfile
	@mkdir -p .iid
	$(DOCKER) build -f _base.Dockerfile --build-arg SOURCE=debian:stable -t javascripten-debian:stable .
	$(DOCKER) build -f _base.Dockerfile --build-arg SOURCE=ubuntu:22.04 -t javascripten-ubuntu:22.04 .
	$(DOCKER) image ls --format={{.Id}} javascripten-debian:stable >.iid/base

.iid/sh: sh/sh.Dockerfile .iid/base
	$(DOCKER) build --iidfile=.iid/sh -f sh/sh.Dockerfile -t javascripten-sh .

# For most runtimes we just use a precompiled release downloaded in 'sh' container
.iid/node: .iid/sh
.iid/bun: .iid/sh
.iid/deno: .iid/sh
.iid/bare: .iid/sh
.iid/llrt: .iid/sh
.iid/ringojs: .iid/sh

# TODO cleanup/rewrite in python
metadata: .PHONY
	@rm -f metadata.tmp
	@for e in $(ENGINES) $(ENGINES_MD); do \
	  echo "$$e"; \
	  df=`ls $$e.Dockerfile 2>/dev/null | head -1`; \
	  rm -rf .meta; \
	  mkdir -p .meta; \
	  f=".meta/text"; \
	  if [[ -f "$$e.md" ]]; then \
	    sed -Ee 's/^[*] (.*)/# \1/; s/^([^#]|$$)/# \1/;' $$e.md >.meta/text; \
	  else \
	    sed -Ene '/#(.*)/p; /^[^#]/q;' "$$df" >.meta/text; \
	  fi; \
	  [[ -f "$$df" ]] && \
	    $(DOCKER) run --rm -v $(PWD)/.meta:/meta javascripten-$$e /bin/bash -c 2>/dev/null " \
	    (cat version || git describe --tags HEAD || git rev-parse --short=8 HEAD) | sed -e s/^v// >/meta/version; \
	    git rev-parse HEAD >/meta/revision; \
	    git log -1 --format='%ad' --date=short HEAD >/meta/revisionDate"; \
	  size=`[[ $$(file -b --mime-type bin/$$e 2>/dev/null) == */*-executable ]] && \
	        [[ $$e != graaljs ]] && \
	        ls -l bin/$$e 2>/dev/null | sed -e 's/  */ /g' | cut -f 5 -d ' '`; \
	  if [[ -f "$$e.md" ]]; then \
	    desc=`sed -Ene 's/. Summary: *(.*)/\1/p' $$e.md`; \
	  else \
	    desc=`sed -Ene '/^[^#]/q; /^#?$$/q; s/# (.*)/\1/p' $$f | \
	          tr '\n' ' ' | sed -e "s/  */ /g; s/ $$//; s/'/\\\\\\'/g"`; \
	  fi; \
	  echo \
	    "'$$e': {" \
	    "'version':  '`cat .meta/version 2>/dev/null || true`'," \
	    "'revision': '`cat .meta/revision 2>/dev/null || true`'," \
	    "'revisionDate': '`cat .meta/revisionDate 2>/dev/null || true`'," \
	    "'repo':     '`sed -Ene 's/ARG JS_REPO=(.*)/\1/p' "$${df}" 2>/dev/null || \
	                   sed -Ene 's/# Repository: *(.*)/\1/p' $$f`'," \
	    "'url':      '`sed -Ene 's/# URL: *(.*)/\1/p'      $$f`'," \
	    "'standard': '`sed -Ene 's/# Standard: *(.*)/\1/p' $$f`'," \
	    "'tech':     '`sed -Ene 's/# Tech: *(.*)/\1/p'     $$f`'," \
	    "'language': '`sed -Ene 's/# Language: *(.*)/\1/p' $$f`'," \
	    "'years':    '`sed -Ene 's/# Timeline: *(.*)/\1/p' $$f`'", \
	    "'org':      '`sed -Ene 's/# Org: *(.*)/\1/p'      $$f`'," \
	    "'note':     \"`sed -Ene 's/# Note: *(.*)/\1/p'     $$f`\"," \
	    "'license':  '`sed -Ene 's/ [(].*//g; s/# License: *(.*)/\1/p' $$f`'," \
	    "'loc':      '`sed -Ene 's/ [(].*//g; s/# LOC: *(.*)/\1/p' $$f`'," \
	    "'binarySize': $${size:-''}," \
	    "'description': '$$desc'," \
	    "}," | sed -Ee "s/'[a-z_]+': *'', *//g" >>metadata.tmp; \
	  rm -rf .meta; \
	done
	node -e "let j=require('fs').readFileSync('metadata.tmp'); j=eval('({'+j+'})'); console.log(JSON.stringify(j, null, 2))" >metadata.json
	mv -f metadata.json "bench/metadata-$$(uname -m | sed -e 's/aarch64/arm64/; s/x86_64/x64/').json"
	@rm -f metadata.tmp

.PHONY:
