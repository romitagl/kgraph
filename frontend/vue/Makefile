include ../../common/common.mk

.PHONY: start
start:
	@echo "starting frontend (dev)"
	. ../../backend/hasura/utils/check-env.sh; verify_hasura_env true
	npm run serve
