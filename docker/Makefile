SHELL    := /bin/bash
ARCH     := $(shell uname -m | sed -e 's/aarch64/arm64/; s/x86_64/x64/')
DOCKER   := $(shell command -v podman 2>/dev/null || echo docker)
IID_DIR  := ../.cache/iid
DIST_DIR := ../dist/$(ARCH)

TARGETS:= $(filter-out base sh, $(patsubst %.Dockerfile,%,$(wildcard [a-z]*.Dockerfile)))

VARIANTS := $(shell cat args.txt | egrep -o '^[-a-z0-9_.]+' | sort -u)
TARGETS := $(sort $(TARGETS) $(VARIANTS))

ifeq ($(ARCH),arm64)
  # chakracode: doesn't support arm64 on linux platform
  # iv-lv5: no JIT on arm64
  # spidermonkey_1.8.5: JIT doesn't support arm64, crash in JIT-less build
  TARGETS := $(filter-out chakracore% iv-lv5_jitless spidermonkey_1.8.5 bali hako starlight,$(TARGETS))
endif

all: base $(TARGETS)

base: $(IID_DIR)/base $(IID_DIR)/sh

dist: $(patsubst %,%-dist,$(TARGETS))
	@true

sh: $(IID_DIR)/sh .PHONY
	$(DOCKER) run \
	  --rm \
	  -v $(PWD)/../bench:/bench \
	  -v $(PWD)/..:/work \
	  -w /work/dist/$(ARCH) \
	  -it \
	  javascripten-sh

$(IID_DIR)/base: base.Dockerfile
	@mkdir -p $(IID_DIR)
	$(DOCKER) build -f base.Dockerfile --build-arg SOURCE=debian:stable -t javascripten-debian:stable .
	$(DOCKER) build -f base.Dockerfile --build-arg SOURCE=ubuntu:22.04 -t javascripten-ubuntu:22.04 .
	$(DOCKER) image ls --format={{.Id}} javascripten-debian:stable >$(IID_DIR)/base

$(IID_DIR)/sh: sh.Dockerfile $(IID_DIR)/base
	$(DOCKER) build --iidfile=$(IID_DIR)/sh -f sh.Dockerfile -t javascripten-sh .

define rules
$(1): $(1)-image $(1)-dist

$(1)-image: $(IID_DIR)/$(1)

$(1)_DEPS = \
  $(IID_DIR)/base \
  $$(shell (egrep -o '^$(1):.* -f [^ ]+.Dockerfile\b' args.txt 2>/dev/null | egrep -o '[^ ]+.Dockerfile\b') || echo "$(1).Dockerfile") \
  $$(shell egrep -q '^$(1):' args.txt 2>/dev/null && echo args.txt)

$(IID_DIR)/$(1): $$($(1)_DEPS)
	./build.sh $(1)

$(1)-dist: $(DIST_DIR)/$(1).json

$(DIST_DIR)/$(1).json: $(IID_DIR)/$(1)
	./dist.sh $(1)

$(1)-repl: $(IID_DIR)/$(1)
	$(DOCKER) run \
	  --rm \
	  -v $(PWD)/../bench:/bench \
	  -it \
	  javascripten-$(1)

$(1)-sh: $(IID_DIR)/$(1)
	$(DOCKER) run \
	  --rm \
	  -v $(PWD)/../bench:/bench \
	  -it \
	  javascripten-$(1) \
	  /bin/bash -c 'ln -sv "$$$$JS_BINARY" "/bin/`basename $$$$JS_BINARY`"; /bin/bash -i'
endef

$(foreach var,$(TARGETS),$(eval $(call rules,$(var))))

clean-docker:
	rm -rf "$(IID_DIR)"
	-$(DOCKER) container prune
	-$(DOCKER) image rm `$(DOCKER) image ls | grep javascripten- | cut -f 1 -d ' '`
	-$(DOCKER) image rm javascripten-debian:stable javascripten-ubuntu:22.04
	$(DOCKER) image prune

.PHONY:
