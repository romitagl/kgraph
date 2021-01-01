#!/bin/bash

docker-compose exec -T postgres pg_dump -s -U postgres -f /shared/schema/hasura-schema-dump-exported.sql -n kgraph postgres
