SHELL    := /bin/bash

DOCKER       := $(shell command -v podman 2>/dev/null || echo docker)
DOCKER_ARCH  := $(shell uname -m | sed -e 's/aarch64/arm64/; s/x86_64/amd64/')
DOCKER_BUILD := $(DOCKER) build --platform linux/$(DOCKER_ARCH)
DOCKER_RUN   := $(DOCKER) run --platform linux/$(DOCKER_ARCH)

IID_DIR  := ../.cache/iid
DIST_DIR := ../dist/$(DOCKER_ARCH)

FILE_TARGETS := $(filter-out build% sh hub, $(patsubst %.Dockerfile,%,$(wildcard [a-z]*.Dockerfile)))
ARGS_TARGETS := $(shell cat args.txt | egrep -o '^[-a-z0-9_.]+' | sort -u)
TARGETS := $(sort $(FILE_TARGETS) $(ARGS_TARGETS))

# chakracode: doesn't support arm64 on Linux
# iv-lv5: no JIT on arm64 - main build is JIT-less
# spidermonkey_1.8.5: JIT doesn't support arm64, crash in JIT-less build
ifeq ($(DOCKER_ARCH),arm64)
  TARGETS := $(filter-out chakracore% iv-lv5_jitless spidermonkey_1.8.5 bali hako starlight,$(TARGETS))
endif

all: base $(TARGETS)

dist: $(patsubst %,%-dist,$(TARGETS)) .PHONY
	@true

base: $(IID_DIR)/base $(IID_DIR)/sh .PHONY
	@true

$(IID_DIR)/base: build*.Dockerfile
	@mkdir -p $(IID_DIR)
	$(DOCKER_BUILD) -t jszoo-debian -t jszoo-debian13 -f build-debian.Dockerfile .
	if [[ `uname -m` == x86_64 ]]; then \
	  $(DOCKER_BUILD) -t jszoo-ubuntu22 -f build-debian.Dockerfile --build-arg BASE=ubuntu:22.04 .; \
	fi
	$(DOCKER_BUILD) -t jszoo-gcc14 -t jszoo-gcc -f build-gcc.Dockerfile --build-arg=VER=14 .
	$(DOCKER_BUILD) -t jszoo-clang20 -t jszoo-clang -f build-clang.Dockerfile --build-arg=VER=20 .
	#$(DOCKER_BUILD) -t jszoo-gcc15 -f build-gcc.Dockerfile --build-arg=VER=15 .
	#$(DOCKER_BUILD) -t jszoo-clang21 -f build-clang.Dockerfile --build-arg=VER=21 .
	$(DOCKER_BUILD) -t jszoo-rust -f build-rust.Dockerfile .
	$(DOCKER) image ls --format={{.Id}} jszoo-debian >$(IID_DIR)/build

sh: $(IID_DIR)/sh .PHONY
	$(DOCKER_RUN) --rm -it \
	  -v $(PWD)/../bench:/bench \
	  -v $(PWD)/../dist/$(DOCKER_ARCH):/dist \
	  jszoo-sh

$(IID_DIR)/sh: sh.Dockerfile $(IID_DIR)/base Makefile
	$(DOCKER_BUILD) --iidfile=$(IID_DIR)/sh -t jszoo-sh -f sh.Dockerfile .

hub: .PHONY
	./hub.sh

define rules
$(1): $(IID_DIR)/$(1) $(DIST_DIR)/$(1).json
	@true

$(IID_DIR)/$(1): $$(shell ./build.sh --dep $(1)) build.sh
	./build.sh $(1)

$(1)-dist: $(DIST_DIR)/$(1).json
	@true

$(DIST_DIR)/$(1).json: $(IID_DIR)/$(1) dist.sh
	./dist.sh $(1)

$(1)-repl: $(IID_DIR)/$(1)
	$(DOCKER_RUN) --rm -it -v $(PWD)/../bench:/bench jszoo-$(1)

$(1)-sh: $(IID_DIR)/$(1)
	$(DOCKER_RUN) --rm -it -v $(PWD)/../bench:/bench jszoo-$(1) \
	  /bin/bash -c '[[ -f $$$$JS_BINARY && ! -f $(1) ]] && ln -sv "$$$$JS_BINARY" "$(1)"; /bin/bash -i'
endef

$(foreach var,$(TARGETS),$(eval $(call rules,$(var))))

# Also consider 'podman system reset' to delete whole podman storage
# for the current user, if things get messed badly.
clean-docker:
	rm -rf "$(IID_DIR)"
	-$(DOCKER) container prune
	-$(DOCKER) image rm `$(DOCKER) image ls | grep jszoo- | cut -f 1 -d ' '`
	$(DOCKER) image prune

.PHONY:
