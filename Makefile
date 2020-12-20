IMAGE_NAME      := dvr
IMAGE_TAG       ?= latest
DOWNLOAD_MODELS ?= 1
USER_ID         := $(shell id -u)
GROUP_ID        := $(shell id -g)

.PHONY: docker-build
docker-build:
	@mkdir -p out
	docker build \
		-f Dockerfile \
		-t $(IMAGE_NAME):$(IMAGE_TAG) \
		--build-arg USER_ID=$(USER_ID) \
		--build-arg GROUP_ID=$(GROUP_ID) \
		--build-arg DOWNLOAD_MODELS=$(DOWNLOAD_MODELS) .
