#!/bin/bash

docker-compose exec -T postgres pg_dump -U postgres -f /shared/schema/hasura-dump-exported.sql -n kgraph postgres
