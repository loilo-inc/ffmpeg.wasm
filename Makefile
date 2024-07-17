.PHONY: all
all: dev

MT_FLAGS := -sUSE_PTHREADS -pthread

DEV_ARGS := --progress=plain

DEV_CFLAGS := --profiling
DEV_MT_CFLAGS := $(DEV_CFLAGS) $(MT_FLAGS)
PROD_CFLAGS := -O3 -msimd128
PROD_MT_CFLAGS := $(PROD_CFLAGS) $(MT_FLAGS)

.PHONY: build
build:
	EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
	EXTRA_LDFLAGS="$(EXTRA_LDFLAGS)" \
	FFMPEG_ST="$(FFMPEG_ST)" \
	FFMPEG_MT="$(FFMPEG_MT)" \
	  docker buildx build \
	    --build-arg EXTRA_CFLAGS \
	    --build-arg EXTRA_LDFLAGS \
	    --build-arg FFMPEG_MT \
	    --build-arg FFMPEG_ST \
	    -o ./packages/core$(PKG_SUFFIX) \
	    $(EXTRA_ARGS) \
	    .

.PHONY: build-st
build-st:
	FFMPEG_ST=yes \
	  $(MAKE) build

.PHONY: build-mt
build-mt:
	PKG_SUFFIX=-mt \
	FFMPEG_MT=yes \
	  $(MAKE) build

.PHONY: clean-st
clean-st:
	rm -rf ./packages/core/dist

.PHONY: clean-mt
clean-mt:
	rm -rf ./packages/core-mt/dist

.PHONY: dev
dev:
	EXTRA_CFLAGS="$(DEV_CFLAGS)" \
	EXTRA_ARGS="$(DEV_ARGS)" \
	  $(MAKE) build-st

.PHONY: dev-mt
dev-mt:
	EXTRA_CFLAGS="$(DEV_MT_CFLAGS)" \
	EXTRA_ARGS="$(DEV_ARGS)" \
	  $(MAKE) build-mt

.PHONY: prd
prd:
	EXTRA_CFLAGS="$(PROD_CFLAGS)" \
	  $(MAKE) build-st

.PHONY: prd-mt
prd-mt:
	EXTRA_CFLAGS="$(PROD_MT_CFLAGS)" \
	  $(MAKE) build-mt
