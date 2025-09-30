SHELL    := /bin/bash
ARCH     := $(shell uname -m | sed -e 's/aarch64/arm64/; s/x86_64/x64/')
DOCKER   := $(shell command -v podman 2>/dev/null || echo docker)
IID_DIR  := ../.cache/iid
DIST_DIR := ../dist/$(ARCH)

ENGINES := $(filter-out base sh, $(patsubst %.Dockerfile,%,$(wildcard [a-z]*.Dockerfile)))
#EXTRA_VARIANTS := $(shell grep '[-]f' args.txt | egrep -o '^[^#:]+' | sort -u)

ifeq ($(ARCH),arm64)
  # chakracode: doesn't support arm64 on linux platform
  # iv-lv5: no JIT on arm64
  # spidermonkey_1.8.5: JIT doesn't support arm64, crash in JIT-less build
  ENGINES := $(filter-out chakracore% iv-lv5_jitless spidermonkey_1.8.5 bali hako starlight,$(ENGINES))
endif

all: base $(ENGINES)

base: $(IID_DIR)/base $(IID_DIR)/sh

dist: $(patsubst %,%-dist,$(ENGINES))
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

$(IID_DIR)/$(1): $(1).Dockerfile $(IID_DIR)/base args.txt
	./build.sh $(1).Dockerfile

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

$(1)-clean:
	$(DOCKER) container prune
	$(DOCKER) image rm -f javascripten-$(1)
	$(DOCKER) image prune
endef

$(foreach var,$(ENGINES),$(eval $(call rules,$(var))))

clean-docker:
	rm -rf "$(IID_DIR)"
	-$(DOCKER) container prune
	-$(DOCKER) image rm `$(DOCKER) image ls | grep javascripten- | cut -f 1 -d ' '`
	-$(DOCKER) image rm javascripten-debian:stable javascripten-ubuntu:22.04
	$(DOCKER) image prune

.PHONY:
