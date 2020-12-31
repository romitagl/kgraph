#!/bin/bash

docker-compose exec -T postgres pg_dump -s -U postgres -f /shared/schema/hasura_schema_dump_exported.sql -n kgraph postgres
