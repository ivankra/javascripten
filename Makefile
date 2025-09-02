SHELL := /bin/bash
DOCKER := $(shell command -v podman 2>/dev/null || echo docker)

ENGINES := $(patsubst %.Dockerfile,%,$(wildcard [a-z]*.Dockerfile))
ifeq ($(shell uname -m),aarch64)
  ENGINES := $(filter-out chakracore%,$(ENGINES))     # doesn't support arm64 linux
  ENGINES := $(filter-out iv-lv5-jitless,$(ENGINES))  # no JIT on arm64 anyway
endif

WIP_ENGINES := $(patsubst wip/%.Dockerfile,%,$(wildcard wip/[a-z]*.Dockerfile))

RUNTIMES := $(patsubst sh/%.Dockerfile,%,$(wildcard sh/[a-z]*.Dockerfile))
RUNTIMES := $(filter-out sh,$(RUNTIMES))

all: base $(ENGINES:%=.iid/%) $(RUNTIMES:%=.iid/%) dist

base: .iid/base .iid/sh

dist: $(patsubst %,dist/%,$(ENGINES)) $(patsubst %,dist/%,$(RUNTIMES))

sh: .iid/sh .PHONY
	$(DOCKER) run --rm -v $(PWD)/bench:/bench -v $(PWD):/work -w /work/dist -it javascripten-sh

clean-docker:
	rm -rf .iid
	-$(DOCKER) container prune
	-$(DOCKER) image rm `$(DOCKER) image ls | grep javascripten- | cut -f 1 -d ' '`
	-$(DOCKER) image rm javascripten-debian:stable javascripten-ubuntu:22.04
	$(DOCKER) image prune

define rules
$(1): .iid/$(1) dist/$(1)
	$(DOCKER) run --rm -v $(PWD)/bench:/bench -it javascripten-$(1)

$(1)-sh: .iid/$(1)
	$(DOCKER) run --rm -v $(PWD)/bench:/bench -it javascripten-$(1) \
		/bin/bash -c 'ln -sv "$$$$JS_BINARY" "/bin/`basename $$$$JS_BINARY`"; /bin/bash -i'

dist/$(1): .iid/$(1)
	@mkdir -p dist
	@rm -f "dist/$(1)"
	@$(DOCKER) run --rm -v $(PWD)/dist:/dist -it javascripten-$(1) /bin/bash -c ' \
	  if [[ -f "$$$$JS_BINARY" ]]; then \
	    strip "$$$$JS_BINARY" 2>/dev/null && cp -fv "$$$$JS_BINARY" "/dist/$(1)"; \
	  elif [[ -f "$$$$JS_BINARY_LINK" ]]; then \
	    ln -sv "$$$$JS_BINARY_LINK" "/dist/$(1)"; \
	  fi' || true

.iid/$(1): $(2)$(1).Dockerfile $(3)
	$(DOCKER) build --iidfile=.iid/$(1) -f $(2)$(1).Dockerfile -t javascripten-$(1) .
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

metadata.json: .PHONY
	@rm -f metadata.tmp
	@for e in $(ENGINES); do \
	  f=`ls {,sh/,wip/}$$e.Dockerfile 2>/dev/null | head -1`; \
	  if ! [ -f "$$f" ]; then continue; fi; \
	  echo "$$f"; \
	  ver=`$(DOCKER) run --rm javascripten-$$e /bin/bash -c 2>/dev/null \
	       "cat version || git describe --tags HEAD || git rev-parse --short=8 HEAD" \
	       | sed -e s/^v//`; \
	  rev=`$(DOCKER) run --rm javascripten-$$e /bin/bash -c 2>/dev/null \
	       "git rev-parse HEAD"`; \
	  size=`[[ $$(file -b --mime-type dist/$$e 2>/dev/null) == */x-*-executable && "$$e" != graaljs ]] && \
	        ls -l dist/$$e 2>/dev/null | sed -e 's/  */ /g' | cut -f 5 -d ' '`; \
	  desc=`sed -Ene 's/# (.*)/\1/p; /^([^#].*|)$$/q' $$f | \
	        tr '\n' ' ' | sed -e "s/  */ /g; s/ $$//; s/'/\\\\\\'/g"`; \
	  echo \
	    "'$$e': {" \
	    "'version':  '$$ver'," \
	    "'revision': '$$rev'," \
	    "'repo':     '`sed -Ene 's/ARG JS_REPO=(.*)/\1/p'  $$f`'," \
	    "'url':      '`sed -Ene 's/# URL: *(.*)/\1/p'      $$f`'," \
	    "'standard': '`sed -Ene 's/# Standard: *(.*)/\1/p' $$f`'," \
	    "'tech':     '`sed -Ene 's/# Tech: *(.*)/\1/p'     $$f`'," \
	    "'language': '`sed -Ene 's/# Language: *(.*)/\1/p' $$f`'," \
	    "'timeline': '`sed -Ene 's/# Timeline: *(.*)/\1/p' $$f`'", \
	    "'org':      '`sed -Ene 's/# Org: *(.*)/\1/p'      $$f`'," \
	    "'note':     '`sed -Ene 's/# Note: *(.*)/\1/p'     $$f`'," \
	    "'license':  '`sed -Ene 's/ [(].*//g; s/# License: *(.*)/\1/p' $$f`'," \
	    "'loc':      '`sed -Ene 's/ [(].*//g; s/# LOC: *(.*)/\1/p' $$f`'," \
	    "'binary_size': $${size:-''}," \
	    "'description': '$$desc'," \
	    "}," | sed -Ee "s/'[a-z_]+': *'', *//g" >>metadata.tmp; \
	done
	node -e "let j=require('fs').readFileSync('metadata.tmp'); j=eval('({'+j+'})'); console.log(JSON.stringify(j, null, 2))" >metadata.json
	@rm -f metadata.tmp

.PHONY:
