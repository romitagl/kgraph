# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /usr/bin/env bash

.PHONY: ci
ci:
	# searches for all Makefile files from the root directory and runs the make ci target on each entry
	# excludes the node_modules folder and root Makefile
	find . -type f -name "Makefile" -not -path "./Makefile" -not -path "*/node_modules/*" -exec dirname {} \; | xargs -I {} make --directory={} ci

.PHONY: publish_docker_images
publish_docker_images:
	# searches for all Dockerfiles from the root directory and runs the Make publish_docker_images target on each entry
	find ./frontend -type f -name "Dockerfile" -exec dirname {} \; | xargs -I {} make --directory={} publish_docker_images
	find ./backend -type f -name "Dockerfile" -exec dirname {} \; | xargs -I {} make --directory={} publish_docker_images