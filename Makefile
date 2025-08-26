DOCKER := $(shell command -v podman 2>/dev/null || echo docker)

ENGINES := $(patsubst %.Dockerfile,%,$(wildcard [a-z]*.Dockerfile))
ifeq ($(shell uname -m),aarch64)
  ENGINES := $(filter-out chakracore%,$(ENGINES))  # doesn't support arm64 linux
  ENGINES := $(filter-out v8%,$(ENGINES))          # wip, buggy toolchain scripts for arm64 linux
endif

RUNTIMES := $(patsubst sh/%.Dockerfile,%,$(wildcard sh/[a-z]*.Dockerfile))
RUNTIMES := $(filter-out sh,$(RUNTIMES))

all: base $(ENGINES:%=.iid/%) $(RUNTIMES:%=.iid/%) dist

base: .iid/base .iid/sh

dist: $(patsubst %,dist/%,$(ENGINES)) $(patsubst %,dist/%,$(RUNTIMES))

sh: .iid/sh .PHONY
	$(DOCKER) run --rm -v $(PWD)/bench:/bench -v $(PWD):/work -w /work/dist -it javascripten-sh

define rules
$(1): .iid/$(1) dist/$(1)
	$(DOCKER) run --rm -v $(PWD)/bench:/bench -it javascripten-$(1)

$(1)-sh: .iid/$(1)
	$(DOCKER) run --rm -v $(PWD)/bench:/bench -it javascripten-$(1) /bin/bash -i

dist/$(1): .iid/$(1)
	@mkdir -p dist
	@rm -f "dist/$(1)"
	@$(DOCKER) run --rm -v $(PWD)/dist:/dist -it javascripten-$(1) /bin/bash -c ' \
	  if [[ -f "$$$$JS_BINARY" ]]; then \
	    strip "$$$$JS_BINARY" && cp -fv "$$$$JS_BINARY" "/dist/$(1)"; \
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

# Most runtimes just use a precompiled release downloaded in 'sh' container
.iid/node: .iid/sh
.iid/bun: .iid/sh
.iid/deno: .iid/sh
.iid/bare: .iid/sh
.iid/llrt: .iid/sh
.iid/ringojs: .iid/sh

.PHONY:
