SHELL := /bin/bash

DOCKER-COMPOSE := . ./env.sh ; docker-compose -f ./docker-compose.yaml

.PHONY: all
all: dependencies start

.PHONY: dependencies
dependencies:
	mkdir -p data 

.PHONY: start
start:
	$(DOCKER-COMPOSE) up -d
	docker-compose logs -f -t 2>&1 | tee docker-compose.log &

.PHONY: stop
stop:
	$(DOCKER-COMPOSE) down

.PHONY: install_schema
install_schema:
	# admin operations can only be initiated from the machine on which the Dgraph Alpha runs
	docker-compose exec server bash /schema/install-schema.sh

.PHONY: clean
clean:
	rm -fr ./data docker-compose.log
	. ./env.sh ; docker rmi -f $$KG_DOCKER_IMAGE:$$KG_DOCKER_IMAGE_VERSION