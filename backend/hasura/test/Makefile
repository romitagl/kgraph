include ../../../common/common.mk

.PHONY: graphql
graphql:
	. ./test-graphql.sh; test_add_topics

.PHONY: import_export
import_export:
	# export data
	bash ../utils/export-data-hasura.sh ; bash ../utils/export-dump-hasura.sh
	# cleanup table records
	. ./test-graphql.sh; test_drop_all_data
	cd ../ && bash ./utils/import-data-hasura.sh
	. ./test-graphql.sh; test_check_ci_topics
	rm ../schema/hasura-data-exported.sql ../schema/hasura-dump-exported.sql
	# cd ../ && bash ../utils/import-dump-hasura.sh
