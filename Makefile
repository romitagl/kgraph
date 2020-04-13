
SHELL := /bin/bash

.PHONY: dgraph
dgraph:
	$(MAKE) --directory=./backend/dgraph all
