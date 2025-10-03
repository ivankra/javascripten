SHELL    := /bin/bash

DOCKER       := $(shell command -v podman 2>/dev/null || echo docker)
DOCKER_ARCH  := $(shell uname -m | sed -e 's/aarch64/arm64/; s/x86_64/amd64/')
DOCKER_BUILD := $(DOCKER) build --platform linux/$(DOCKER_ARCH)
DOCKER_RUN   := $(DOCKER) run --platform linux/$(DOCKER_ARCH)

IID_DIR  := ../.cache/iid
DIST_DIR := ../dist/$(DOCKER_ARCH)

FILE_TARGETS := $(filter-out base%, $(patsubst %.Dockerfile,%,$(wildcard [a-z]*.Dockerfile)))
ARGS_TARGETS := $(shell cat args.txt | egrep -o '^[-a-z0-9_.]+' | sort -u)
TARGETS := $(sort $(FILE_TARGETS) $(ARGS_TARGETS))

# chakracode: doesn't support arm64 on Linux
# iv-lv5: no JIT on arm64 - main build is JIT-less
# spidermonkey_1.8.5: JIT doesn't support arm64, crash in JIT-less build
ifeq ($(DOCKER_ARCH),arm64)
  TARGETS := $(filter-out chakracore% iv-lv5_jitless spidermonkey_1.8.5 bali hako starlight,$(TARGETS))
endif

all: base $(TARGETS)

dist: $(patsubst %,%-dist,$(TARGETS))
	@true

sh: $(IID_DIR)/runtime
	$(DOCKER_RUN) --rm -it \
	  -v $(PWD)/../bench:/bench \
	  -v $(PWD)/../dist/$(DOCKER_ARCH):/dist \
	  jsz-runtime

hub:
	./hub.sh

base: $(IID_DIR)/base
	@true

$(IID_DIR)/base: base*.Dockerfile $(IID_DIR)/runtime
	@mkdir -p $(IID_DIR)
	$(DOCKER_BUILD) -t jsz-debian -t jsz-debian13 -f base-debian.Dockerfile .
	if [[ `uname -m` == x86_64 ]]; then \
	  $(DOCKER_BUILD) -t jsz-ubuntu22 -f base-debian.Dockerfile --build-arg BASE=ubuntu:22.04 .; \
	fi
	$(DOCKER_BUILD) -t jsz-gcc14 -t jsz-gcc -f base-gcc.Dockerfile --build-arg=VER=14 .
	$(DOCKER_BUILD) -t jsz-clang20 -t jsz-clang -f base-clang.Dockerfile --build-arg=VER=20 .
	#$(DOCKER_BUILD) -t jsz-gcc15 -f base-gcc.Dockerfile --build-arg=VER=15 .
	#$(DOCKER_BUILD) -t jsz-clang21 -f base-clang.Dockerfile --build-arg=VER=21 .
	$(DOCKER_BUILD) -t jsz-golang -f base-golang.Dockerfile .
	$(DOCKER_BUILD) -t jsz-node -f base-node.Dockerfile .
	$(DOCKER_BUILD) -t jsz-rust -f base-rust.Dockerfile .
	$(DOCKER) image ls --format={{.Id}} jsz-debian >$(IID_DIR)/base

$(IID_DIR)/runtime: base-runtime.Dockerfile
	$(DOCKER_BUILD) --iidfile=$(IID_DIR)/runtime -t jsz-runtime --target=jsz-runtime -f base-runtime.Dockerfile .

define rules
$(1): $(IID_DIR)/$(1) $(DIST_DIR)/$(1).json
	@true

$(IID_DIR)/$(1): $(IID_DIR)/base $$(shell ./build.sh --dep $(1)) build.sh
	./build.sh $(1)

$(1)-dist: $(DIST_DIR)/$(1).json
	@true

$(DIST_DIR)/$(1).json: $(IID_DIR)/$(1) dist.sh
	./dist.sh $(1)

$(1)-repl: $(IID_DIR)/$(1)
	$(DOCKER_RUN) --rm -it -v $(PWD)/../bench:/bench jsz-$(1)

$(1)-sh: $(IID_DIR)/$(1)
	$(DOCKER_RUN) --rm -it -v $(PWD)/../bench:/bench jsz-$(1) \
	  /bin/bash -c '[[ -f $$$$JS_BINARY && ! -f $(1) ]] && ln -sv "$$$$JS_BINARY" "./$(1)"; /bin/bash -i'
endef

$(foreach var,$(TARGETS),$(eval $(call rules,$(var))))

# Also consider 'podman system reset' to delete whole podman storage
# for the current user, if things get messed badly.
clean-docker:
	rm -rf "$(IID_DIR)"
	-$(DOCKER) container prune
	-$(DOCKER) image rm `$(DOCKER) image ls | grep jsz- | cut -f 1 -d ' '`
	$(DOCKER) image prune

.PHONY:
