include ../../common/common.mk

.PHONY: start
start:
	@echo "starting frontend (dev)"
	# . ../../backend/hasura/utils/check-env.sh; verify_hasura_env true
	npm run serve

.PHONY: start_demo
start_demo:
	@echo "starting frontend in demo mode"
	npm run serve -- --mode=demo

PHONY: run_docker
run_docker:
	@echo "Run Docker image $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)"
	docker run --rm --name frontend -p 80:80 $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)
