include ../../common/common.mk

.PHONY: ci
ci:: dependencies start install_schema_and_metadata test stop

.PHONY: dependencies
dependencies:
	. ./utils/check-env.sh; verify_hasura_running
	sudo rm -fr ./postgresql docker-compose.log ; mkdir -p postgresql 

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
	until nc -z localhost 8080; do echo "waiting for Hasura service to be ready - retrying in 10 seconds..."; sleep 10; done
	@echo $(shell echo `pwd` )
	sh ./utils/import-schema-hasura.sh
	sh -x ./utils/import-metadata-hasura.sh ./schema/hasura-metadata-dump.json

.PHONY: test
test:
	# run graphql + import/export t tests
	export HASURA_CURL_POST_COMMAND="curl -H X-Hasura-Admin-Secret:$$HASURA_GRAPHQL_ADMIN_SECRET -d" && \
	  export HASURA_GRAPHQL_ENDPOINT="http://localhost:8080/v1/graphql" && \
		make --directory=./test graphql import_export
