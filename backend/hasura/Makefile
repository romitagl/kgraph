include ../../common/common.mk

CI_ENV := export HASURA_CURL_POST_COMMAND="curl -v -H X-Hasura-Admin-Secret:$$HASURA_GRAPHQL_ADMIN_SECRET -d" && \
	  export HASURA_GRAPHQL_ENDPOINT="http://127.0.0.1:8080/v1/graphql"

.PHONY: ci
ci:: dependencies start install_schema_and_metadata add_default_config test stop

.PHONY: dependencies
dependencies:
	. ./utils/check-env.sh; verify_hasura_running
	docker volume rm -f hasura_postgres_data
	rm -fr docker-compose.log

.PHONY: start
start:
	. ./utils/check-env.sh; verify_hasura_env false
	docker-compose -f ./docker-compose.yaml up -d graphql-engine
	docker-compose logs -f -t 2>&1 | tee docker-compose.log &

.PHONY: stop
stop:
	docker-compose -f ./docker-compose.yaml down

.PHONY: install_schema_and_metadata
install_schema_and_metadata:
	@echo "installing sql schema and graphql metadata"
	until docker-compose exec -T postgres pg_isready; do echo "waiting for Postgresql service to be ready - retrying in 10 seconds..."; sleep 10; done
	until nc -z 127.0.0.1 8080; do echo "waiting for GraphQL endpoint to be ready - retrying in 10 seconds..."; sleep 10; done
	@echo $(shell pwd)
	bash ./utils/import-schema-hasura.sh
	bash -x ./utils/import-metadata-hasura.sh ./schema/hasura-metadata-dump.json

.PHONY: add_default_config
add_default_config:
	$(CI_ENV) && bash -x ./schema/add-default-postgres-config.sh

.PHONY: test
test:
	# run graphql + import/export tests
	$(CI_ENV) && \
		make --directory=./test graphql import_export
	$(CI_ENV) && \
		make --directory=./auth test