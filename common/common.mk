# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /usr/bin/env bash

# GitHub Docker Registry
# https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-docker-registry
REGISTRY_URL="docker.pkg.github.com"
OWNER="romitagl"
REPOSITORY="kgraph"
FILE_PATH=$(shell git ls-files --full-name Makefile | sed -e "s/Makefile//g" )
DOCKER_IMAGE_NAME=$(shell echo $(FILE_PATH) | sed -e "s/\//-/g" | rev | cut -c2- | rev )
GIT_SHA=$(shell git rev-parse HEAD)
# git tag | tail -n 1
GIT_TAG=$(shell git describe --abbrev=0 --tags)
DOCKER_IMAGE_VERSION=$(GIT_TAG)

.PHONY: ci
ci::
	@echo "running ci target"

PHONY: build_docker
build_docker:
	@echo "Building Docker image $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)"
	[ -e "./Dockerfile" ] && docker build -f ./Dockerfile --no-cache -t $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) . || echo "no Docker image to build"

.PHONY: tag_docker_images
tag_docker_images: build_docker
	@echo "Pushing to the container registry"
	# docker tag IMAGE_ID docker.pkg.github.com/OWNER/REPOSITORY/IMAGE_NAME:VERSION
	# [ -e "./Dockerfile" ] && [ ! -z $(REGISTRY_URL) ] && docker tag $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) $(REGISTRY_URL)/$(OWNER)/$(REPOSITORY)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) || echo "no Docker image to tag"
	# Docker Hub
	[ -e "./Dockerfile" ] && [ ! -z $(REGISTRY_URL) ] && docker tag $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) $(OWNER)/$(REPOSITORY)-$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) || echo "no Docker image to tag"
	# set the latest tag
	[ -e "./Dockerfile" ] && [ ! -z $(REGISTRY_URL) ] && docker tag $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) $(OWNER)/$(REPOSITORY)-$(DOCKER_IMAGE_NAME):latest || echo "no latest Docker image to tag"

.PHONY: publish_docker_images
publish_docker_images: tag_docker_images
	@echo "Pushing to the container registry"
	# docker tag IMAGE_ID docker.pkg.github.com/OWNER/REPOSITORY/IMAGE_NAME:VERSION
	# [ -e "./Dockerfile" ] && [ ! -z $(REGISTRY_URL) ] && docker push $(REGISTRY_URL)/$(OWNER)/$(REPOSITORY)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) || echo "no Docker image to push"
	# Docker Hub
	[ -e "./Dockerfile" ] && [ ! -z $(REGISTRY_URL) ] && docker push $(OWNER)/$(REPOSITORY)-$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) || echo "no Docker image to push"
	# set the latest tag
	[ -e "./Dockerfile" ] && [ ! -z $(REGISTRY_URL) ] && docker push $(OWNER)/$(REPOSITORY)-$(DOCKER_IMAGE_NAME):latest || echo "no latest Docker image to push"

.PHONY: clean
clean::
	docker rmi -f $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)