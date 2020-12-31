#!/bin/bash

docker-compose exec -T postgres pg_dump -U postgres -f /shared/schema/hasura_dump_exported.sql -n kgraph postgres
