# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /usr/bin/env bash

.PHONY: ci
ci::
	@echo "running ci target"